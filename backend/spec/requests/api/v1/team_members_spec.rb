require 'rails_helper'

RSpec.describe 'Api::V1::TeamMembers', type: :request do
  describe 'GET /api/v1/team_members' do
    it 'returns all team members sorted by name with status 200' do
      member2 = create(:team_member, name: 'Zoe')
      member1 = create(:team_member, name: 'Alice')

      get '/api/v1/team_members'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('team_members')

      names = json['team_members'].map { |m| m['name'] }
      expect(names).to eq(names.sort)
    end
  end

  describe 'POST /api/v1/team_members' do
    let(:valid_params) do
      {
        team_member: {
          name: 'Jane Doe',
          email: 'jane@example.com',
          role: 'developer',
          active: true
        }
      }
    end

    it 'creates a new team member and returns status 201' do
      expect {
        post '/api/v1/team_members', params: valid_params
      }.to change(TeamMember, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json).to include(
        'name' => 'Jane Doe',
        'email' => 'jane@example.com',
        'role' => 'developer',
        'active' => true
      )
      expect(json).to have_key('id')
      expect(json).to have_key('created_at')
      expect(json).to have_key('updated_at')
    end

    it 'returns status 422 with error and details for invalid params' do
      invalid_params = { team_member: { name: '', email: 'invalid-email' } }

      post '/api/v1/team_members', params: invalid_params

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json).to have_key('error')
      expect(json).to have_key('details')
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to be_an(Array)
    end
  end

  describe 'PATCH /api/v1/team_members/:id' do
    let!(:member) { create(:team_member, active: true) }

    it 'updates the team member and returns status 200' do
      patch "/api/v1/team_members/#{member.id}", params: { team_member: { active: false } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['active']).to be false
      expect(member.reload.active).to be false
    end

    it 'returns status 404 for a non-existent team member ID' do
      patch '/api/v1/team_members/999999', params: { team_member: { active: false } }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Team member not found')
    end
  end
end
