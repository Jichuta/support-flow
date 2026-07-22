require "rails_helper"

RSpec.describe SupportRequest, type: :model do
  describe "validations" do
    subject(:support_request) { build(:support_request) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to validate_presence_of(:creator) }
    it { is_expected.to validate_presence_of(:team) }

    it "rejects an inactive assignee" do
      support_request.assignee = build(:team_member, active: false)

      expect(support_request).to be_invalid
      expect(support_request.errors[:assignee]).to include("must be active")
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(open: 0, in_progress: 1, resolved: 2, closed: 3) }
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, critical: 3) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:creator).class_name("TeamMember") }
    it { is_expected.to belong_to(:assignee).class_name("TeamMember").optional }
    it { is_expected.to belong_to(:team).class_name("TeamMember") }
    it "defines comments as a dependent-destroy association" do
      association = described_class.reflect_on_association(:comments)

      expect(association.macro).to eq(:has_many)
      expect(association.class_name).to eq("Comment")
      expect(association.options[:dependent]).to eq(:destroy)
    end
  end

  describe "resolution lifecycle" do
    it "sets resolved_at when the request becomes resolved" do
      support_request = create(:support_request)
      allow(support_request).to receive(:comments).and_return(double(exists?: true))

      support_request.update!(status: :resolved)

      expect(support_request.resolved_at).to be_present
    end

    it "clears resolved_at when the request leaves resolved" do
      support_request = create(:support_request)
      allow(support_request).to receive(:comments).and_return(double(exists?: true))
      support_request.update!(status: :resolved)

      support_request.update!(status: :in_progress)

      expect(support_request.resolved_at).to be_nil
    end

    it "requires a comment before resolving" do
      support_request = create(:support_request)
      allow(support_request).to receive(:comments).and_return(double(exists?: false))

      expect(support_request.update(status: :resolved)).to be(false)
      expect(support_request.errors[:comments]).to include("must include at least one comment before resolving")
    end
  end

  describe "closed request restrictions" do
    it "cannot return a closed request to open" do
      support_request = create(:support_request)
      support_request.update!(status: :closed)

      expect(support_request.update(status: :open)).to be(false)
      expect(support_request.errors[:status]).to include("cannot return to open once closed")
    end

    it "cannot edit a closed request" do
      support_request = create(:support_request)
      support_request.update!(status: :closed)

      expect(support_request.update(title: "Updated title")).to be(false)
      expect(support_request.errors[:base]).to include("Closed requests cannot be edited")
    end
  end

  describe "overdue behavior" do
    it "is overdue when its due date has passed and it is unresolved" do
      support_request = build(:support_request, due_date: Date.current - 1.day)

      expect(support_request).to be_overdue
    end

    it "is not overdue when resolved or closed" do
      resolved_request = build(:support_request, status: :resolved, due_date: Date.current - 1.day)
      closed_request = build(:support_request, status: :closed, due_date: Date.current - 1.day)

      expect(resolved_request).not_to be_overdue
      expect(closed_request).not_to be_overdue
    end

    it "returns only overdue requests from the overdue scope" do
      overdue_request = create(:support_request, due_date: Date.current - 1.day)
      current_request = create(:support_request, due_date: Date.current)
      closed_request = create(:support_request, due_date: Date.current - 1.day)
      closed_request.update!(status: :closed)
      resolved_request = create(:support_request, due_date: Date.current - 1.day)
      allow(resolved_request).to receive(:comments).and_return(double(exists?: true))
      resolved_request.update!(status: :resolved)

      expect(described_class.overdue).to include(overdue_request)
      expect(described_class.overdue).not_to include(current_request, closed_request, resolved_request)
    end
  end
end