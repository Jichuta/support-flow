require "rails_helper"

RSpec.describe "Api::V1::Comments", type: :request do
  describe "POST /api/v1/support_requests/:support_request_id/comments" do
    let(:support_request) { create(:support_request) }
    let(:team_member) { create(:team_member) }

    context "with valid params" do
      let(:valid_params) do
        {
          comment: {
            body: "This is a detailed comment on the support request",
            team_member_id: team_member.id
          }
        }
      end

      it "creates a comment and returns 201" do
        expect {
          post "/api/v1/support_requests/#{support_request.id}/comments", params: valid_params
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json).to include(
          "id" => a_value,
          "body" => "This is a detailed comment on the support request",
          "author_name" => team_member.name,
          "support_request_id" => support_request.id
        )
        expect(json).to have_key("created_at")
      end
    end

    context "with body too short" do
      let(:short_params) do
        {
          comment: {
            body: "Short",
            team_member_id: team_member.id
          }
        }
      end

      it "returns 422 with validation error" do
        post "/api/v1/support_requests/#{support_request.id}/comments", params: short_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Validation failed")
        expect(json["details"]).to be_an(Array)
        expect(json["details"].first).to include("too short")
      end
    end

    context "with missing team_member_id" do
      let(:missing_member_params) do
        {
          comment: {
            body: "This comment is missing a team member association"
          }
        }
      end

      it "returns 422 with validation error" do
        post "/api/v1/support_requests/#{support_request.id}/comments", params: missing_member_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Validation failed")
        expect(json["details"]).to be_an(Array)
      end
    end

    context "when support request does not exist" do
      let(:valid_params) do
        {
          comment: {
            body: "This comment references a non-existent support request",
            team_member_id: team_member.id
          }
        }
      end

      it "returns 404" do
        post "/api/v1/support_requests/999999/comments", params: valid_params

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not found")
        expect(json["details"]).to be_an(Array)
      end
    end

    context "when support request is closed" do
      let!(:closed_request) { create(:support_request, status: :closed) }

      it "allows adding a comment and returns 201" do
        params = {
          comment: {
            body: "Comment added to a closed support request",
            team_member_id: team_member.id
          }
        }

        expect {
          post "/api/v1/support_requests/#{closed_request.id}/comments", params: params
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["support_request_id"]).to eq(closed_request.id)
      end
    end
  end
end
