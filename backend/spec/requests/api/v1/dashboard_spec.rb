require "rails_helper"

RSpec.describe "Api::V1::Dashboard", type: :request do
  describe "GET /api/v1/dashboard" do
    it "returns 200 with correct structure" do
      get "/api/v1/dashboard"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to include(
        "total_requests",
        "requests_by_status",
        "requests_by_priority",
        "requests_by_team"
      )
    end

    it "returns correct totals and aggregations" do
      team_a = create(:team_member, name: "Alice")
      team_b = create(:team_member, name: "Bob")

      create(:support_request, status: :open, priority: :low, team: team_a)
      create(:support_request, status: :open, priority: :medium, team: team_a)
      create(:support_request, status: :in_progress, priority: :high, team: team_b)

      resolved = create(:support_request, status: :in_progress, priority: :low, team: team_b)
      create(:comment, support_request: resolved, team_member: team_b)
      resolved.update!(status: :resolved)

      closed = create(:support_request, status: :open, priority: :critical, team: team_a)
      closed.update!(status: :closed)

      get "/api/v1/dashboard"

      json = JSON.parse(response.body)

      expect(json["total_requests"]).to eq(5)

      expect(json["requests_by_status"]).to include(
        "open" => 2,
        "in_progress" => 1,
        "resolved" => 1,
        "closed" => 1
      )

      expect(json["requests_by_priority"]).to include(
        "low" => 2,
        "medium" => 1,
        "high" => 1,
        "critical" => 1
      )

      team_counts = json["requests_by_team"].map { |t| [t["name"], t["count"]] }.to_h
      expect(team_counts["Alice"]).to eq(3)
      expect(team_counts["Bob"]).to eq(2)
    end

    it "returns empty aggregations when no requests exist" do
      get "/api/v1/dashboard"

      json = JSON.parse(response.body)
      expect(json["total_requests"]).to eq(0)
      expect(json["requests_by_status"]).to be_empty
      expect(json["requests_by_priority"]).to be_empty
      expect(json["requests_by_team"]).to be_empty
    end
  end
end
