require 'rails_helper'

describe RecoveryController do
  include ResponseHelper

  let!(:user) { FactoryBot.create(:user) }

  describe 'recovery' do
  end

  describe 'reset_password' do
    context 'success' do

      before do
        post :create, params: { email: user.email }
      end

      it 'sends recovery token to email' do
        expect(response).to have_http_status(:accepted)
        expect(response_json['status']).to eq("Recovery email sent to #{user.email}")
      end
    end

    context 'failure' do

      before do
        post :create, params: {}
      end

      it do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'non existent email' do

      before do
        post :create, params: { email: 'non@existent.com' }
      end

      it 'has successfull response' do
        expect(response).to have_http_status(:accepted)
        expect(response_json['status']).to eq("Recovery email sent to non@existent.com")
      end
    end

  end
end
