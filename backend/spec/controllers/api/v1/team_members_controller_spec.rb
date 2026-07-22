require 'rails_helper'

RSpec.describe Api::V1::TeamMembersController, type: :controller do
  describe 'GET #index' do
    it 'assigns @team_members ordered by name and returns json' do
      member2 = create(:team_member, name: 'Zoe')
      member1 = create(:team_member, name: 'Alice')

      get :index

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['team_members'].first['id']).to eq(member1.id)
      expect(json['team_members'].last['id']).to eq(member2.id)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_attributes) do
        { name: 'John Doe', email: 'john.doe@example.com', role: 'developer', active: true }
      end

      it 'creates a new TeamMember' do
        expect {
          post :create, params: { team_member: valid_attributes }
        }.to change(TeamMember, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) do
        { name: '', email: 'invalid_email' }
      end

      it 'does not create a new TeamMember and renders unprocessable_entity' do
        expect {
          post :create, params: { team_member: invalid_attributes }
        }.not_to change(TeamMember, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Validation failed')
        expect(json['details']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH #update' do
    let!(:member) { create(:team_member, active: true) }

    context 'with valid parameters' do
      it 'updates the requested team_member' do
        patch :update, params: { id: member.id, team_member: { active: false } }
        expect(response).to have_http_status(:ok)
        expect(member.reload.active).to be false
      end
    end

    context 'with invalid parameters' do
      it 'renders unprocessable_entity' do
        patch :update, params: { id: member.id, team_member: { email: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when team member is not found' do
      it 'returns 404 not found' do
        patch :update, params: { id: 999999, team_member: { active: false } }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Team member not found')
      end
    end
  end
end
