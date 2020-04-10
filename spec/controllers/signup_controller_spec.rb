require 'rails_helper'

describe SignupController, :type => :controller do
  describe 'POST #create' do
    context 'success' do
      it  do
        user = FactoryBot.build(:user)
        post :create, params: { name: user.name,
                                  email: user.email,
                                  password: user.password }
        expect(response).to have_http_status(201)
      end
    end
  end
end
