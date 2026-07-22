require "rails_helper"

RSpec.describe "Error Handling", type: :request do
  describe "ActiveRecord::RecordNotFound" do
    it "returns 404 with error and details" do
      get "/api/v1/test_errors/record_not_found"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not found")
      expect(json["details"]).to be_an(Array)
      expect(json["details"].first).to include("Test record not found")
    end
  end

  describe "ActiveRecord::RecordInvalid" do
    it "returns 422 with error and details" do
      get "/api/v1/test_errors/record_invalid"

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Validation failed")
      expect(json["details"]).to be_an(Array)
      expect(json["details"]).not_to be_empty
    end
  end

  describe "render_error helper" do
    it "returns custom error with message, details, and status" do
      get "/api/v1/test_errors/custom_error"

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Custom error message")
      expect(json["details"]).to eq(["Detail one", "Detail two"])
    end
  end
end
