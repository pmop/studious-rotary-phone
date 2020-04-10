require 'rails_helper'

describe SignupController, :type => :controller do

  context 'account management' do

    describe 'POST #create' do
      context 'success' do
        it  do
          user = FactoryBot.build(:user)
          post '/signup', params: { name: user.name,
                                    email: user.email,
                                    password: user.password }
          expect(response).to have_http_status(201)
        end
      end
    end

    context 'authentication' do
      let!(:user) { FactoryBot.create(:user) } 

      it 'responds with ACCEPTED status' do
        post '/auth', params: { email: user.email,
                                password: user.password }
        expect(response).to have_http_status(202)
      end
    end

    context 'authentication' do
      let!(:user) { FactoryBot.create(:user) } 

      it 'responds with ACCEPTED status' do
        post '/auth', params: { email: user.email,
                                password: user.password }
        expect(response).to have_http_status(202)
        expect(response.body).to include('csrf')
        expect(cookies).to include('jwt_access')
      end
    end

    context 'authenticated' do 
      # Authenticate user first
      before do
        user = FactoryBot.create(:user)
        post '/auth', params: { email: user.email,
                                password: user.password }
        expect(response).to have_http_status(202)
        expect(response.body).to include('csrf')
        expect(cookies).to include('jwt_access')
      end

      context 'user logs out' do
        it 'responds with OK status' do
          expect(response.body).to include('csrf')
          expect(cookies).to include('jwt_access')
          csrf = response.body['csrf']
          request.headers[JWTSessions.access_header] = csrf
          request.headers[JWTSessions.csrf_header] = cookies['jwt_access']
          delete '/auth'
          expect(response).to have_http_status(200)
        end
      end
    end

  end
end
