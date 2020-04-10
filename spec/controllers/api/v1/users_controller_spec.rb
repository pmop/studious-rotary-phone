require 'rails_helper'

describe Api::V1::UsersController do

  let!(:user) { FactoryBot.create(:user) }

  describe 'GET #index' do
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      context 'headers' do
        let(:access_token) { "Bearer #{@tokens[:access]}" }
        before do
          request.headers[JWTSessions.access_header] = access_token
          get :index
        end

        it do
          expect(response).to be_successful
          expect(response.body).to eq( user.as_json )
        end
      end
    end
  end

#   describe 'PATCH #update' do
  # end
# 
#   describe 'DELETE #destroy' do
  # end
end
