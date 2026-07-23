require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  describe 'validations' do
    subject { create(:team_member) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:role) }

    it 'is valid with a proper email format' do
      member = build(:team_member, email: 'user@example.com')
      expect(member).to be_valid
    end

    it 'is invalid with an improper email format' do
      member = build(:team_member, email: 'invalid-email')
      expect(member).not_to be_valid
      expect(member.errors[:email]).to include('is invalid')
    end
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(developer: 0, qa: 1, support: 2) }
  end

  describe 'associations' do
    it 'defines has_many :created_requests' do
      assoc = TeamMember.reflect_on_association(:created_requests)
      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:class_name]).to eq('SupportRequest')
      expect(assoc.options[:foreign_key]).to eq(:creator_id)
      expect(assoc.options[:dependent]).to eq(:restrict_with_error)
    end

    it 'defines has_many :assigned_requests' do
      assoc = TeamMember.reflect_on_association(:assigned_requests)
      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:class_name]).to eq('SupportRequest')
      expect(assoc.options[:foreign_key]).to eq(:assignee_id)
      expect(assoc.options[:dependent]).to eq(:nullify)
    end

    it 'defines has_many :comments' do
      assoc = TeamMember.reflect_on_association(:comments)
      expect(assoc.macro).to eq(:has_many)
      expect(assoc.options[:dependent]).to eq(:restrict_with_error)
    end
  end

  describe 'scopes and defaults' do
    it 'defaults active to true' do
      member = create(:team_member)
      expect(member.active).to be true
    end

    it 'filters active team members using .active scope' do
      active_member = create(:team_member, active: true)
      inactive_member = create(:team_member, active: false)

      expect(TeamMember.active).to include(active_member)
      expect(TeamMember.active).not_to include(inactive_member)
    end
  end
end
