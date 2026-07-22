require "rails_helper"

RSpec.describe "Api::V1::SupportRequests", type: :request do
  let(:creator) { create(:team_member, name: "Creator") }
  let(:team) { create(:team_member, name: "Team") }
  let(:assignee) { create(:team_member, name: "Assignee") }

  describe "GET /api/v1/support_requests" do
    it "returns support requests with their computed overdue value" do
      overdue_request = create(:support_request, title: "Past due request", due_date: Date.current - 1.day, creator: creator, team: team)
      current_request = create(:support_request, title: "Current request", due_date: Date.current, creator: creator, team: team)

      get "/api/v1/support_requests"

      expect(response).to have_http_status(:ok)
      requests = JSON.parse(response.body).fetch("support_requests")
      overdue_payload = requests.find { |request| request["id"] == overdue_request.id }
      current_payload = requests.find { |request| request["id"] == current_request.id }

      expect(overdue_payload["overdue"]).to be(true)
      expect(current_payload["overdue"]).to be(false)
    end

    it "filters by status and priority" do
      matching_request = create(:support_request, status: :open, priority: :high, creator: creator, team: team)
      create(:support_request, status: :open, priority: :low, creator: creator, team: team)
      create(:support_request, status: :in_progress, priority: :high, creator: creator, team: team)

      get "/api/v1/support_requests", params: { status: "open", priority: "high" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).fetch("support_requests").pluck("id")).to eq([matching_request.id])
    end

    it "filters by assignee using team_member_id" do
      assigned_request = create(:support_request, assignee: assignee, creator: creator, team: team)
      create(:support_request, creator: creator, team: team)

      get "/api/v1/support_requests", params: { team_member_id: assignee.id }

      expect(JSON.parse(response.body).fetch("support_requests").pluck("id")).to eq([assigned_request.id])
    end

    it "filters overdue and unassigned requests" do
      matching_request = create(:support_request, due_date: Date.current - 1.day, creator: creator, team: team, assignee: nil)
      create(:support_request, due_date: Date.current - 1.day, creator: creator, team: team, assignee: assignee)
      create(:support_request, due_date: Date.current + 1.day, creator: creator, team: team, assignee: nil)

      get "/api/v1/support_requests", params: { overdue: true, unassigned: true }

      expect(JSON.parse(response.body).fetch("support_requests").pluck("id")).to eq([matching_request.id])
    end

    it "filters titles case-insensitively" do
      matching_request = create(:support_request, title: "Login portal failure", creator: creator, team: team)
      create(:support_request, title: "Invoice export failure", creator: creator, team: team)

      get "/api/v1/support_requests", params: { q: "PORTAL" }

      expect(JSON.parse(response.body).fetch("support_requests").pluck("id")).to eq([matching_request.id])
    end
  end

  describe "GET /api/v1/support_requests/:id" do
    it "returns request details with full assignee data and nested comments" do
      support_request = create(:support_request, assignee: assignee, creator: creator, team: team)
      comment = create(:comment, support_request: support_request, team_member: creator, body: "This comment contains enough detail.")

      get "/api/v1/support_requests/#{support_request.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include("id" => support_request.id, "title" => support_request.title)
      expect(json.fetch("assignee")).to include("id" => assignee.id, "name" => assignee.name, "email" => assignee.email)
      expect(json.fetch("comments")).to include(
        include("id" => comment.id, "body" => comment.body, "author_name" => creator.name)
      )
    end

    it "returns 404 when the request does not exist" do
      get "/api/v1/support_requests/999999"

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body).fetch("error")).to eq("Not found")
    end
  end

  describe "POST /api/v1/support_requests" do
    let(:valid_params) do
      {
        support_request: {
          title: "New customer issue",
          description: "A customer needs help with an account setting.",
          priority: "high",
          due_date: Date.current + 2.days,
          creator_id: creator.id,
          team_id: team.id,
          assignee_id: assignee.id
        }
      }
    end

    it "creates a support request with status 201" do
      expect {
        post "/api/v1/support_requests", params: valid_params
      }.to change(SupportRequest, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include("title" => "New customer issue", "priority" => "high", "overdue" => false)
    end

    it "returns 422 for invalid request data" do
      post "/api/v1/support_requests", params: valid_params.deep_merge(support_request: { title: "" })

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to include("error" => "Validation failed")
      expect(json.fetch("details")).to include("Title can't be blank")
    end

    it "enforces the inactive-assignee rule" do
      inactive_assignee = create(:team_member, active: false)

      post "/api/v1/support_requests", params: valid_params.deep_merge(support_request: { assignee_id: inactive_assignee.id })

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).fetch("details")).to include("Assignee must be active")
    end
  end

  describe "PATCH /api/v1/support_requests/:id" do
    it "updates a support request" do
      support_request = create(:support_request, creator: creator, team: team)

      patch "/api/v1/support_requests/#{support_request.id}", params: { support_request: { priority: "critical", assignee_id: assignee.id } }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("priority" => "critical", "assignee" => include("id" => assignee.id))
      expect(support_request.reload).to have_attributes(priority: "critical", assignee: assignee)
    end

    it "returns 422 when trying to edit a closed request" do
      support_request = create(:support_request, creator: creator, team: team)
      support_request.update!(status: :closed)

      patch "/api/v1/support_requests/#{support_request.id}", params: { support_request: { title: "Changed title" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body).fetch("details")).to include("Closed requests cannot be edited")
    end
  end
end