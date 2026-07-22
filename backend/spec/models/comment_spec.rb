require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:body).is_at_least(10) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:support_request) }
    it { is_expected.to belong_to(:team_member) }
  end

  describe "factory" do
    it "has a valid default factory" do
      expect(build(:comment)).to be_valid
    end
  end
end
