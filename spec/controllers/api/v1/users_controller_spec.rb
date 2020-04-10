require 'rails_helper'

describe Api::V1::UsersController do


  describe 'GET #index' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
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

    context 'failure' do
      context 'no access token' do
        before { get :index }

        it { expect(response.code).to eq '401' }
      end

      context 'incorrect access token' do
        it do
          request.cookies[JWTSessions.access_cookie] = '123abc'
          get :index
          expect(response.code).to eq '401'
        end

        it do
          request.headers[JWTSessions.access_header] = 'abc123'
          get :index
          expect(response.code).to eq '401'
        end
      end

      context 'flushed tokens' do
        let(:access_token) { "Bearer #{@tokens[:access]}" }
        let(:access_cookie) { @tokens[:access] }

        it do
          request.headers[JWTSessions.access_header] = access_token
          session = JWTSessions::Session.new
          session.flush_by_token(@tokens[:refresh])
          get :index
          expect(response.code).to eq '401'
        end

        it do
          request.cookies[JWTSessions.access_cookie] = access_cookie
          session = JWTSessions::Session.new
          session.flush_by_token(@tokens[:refresh])
          get :index
          expect(response.code).to eq '401'
        end
      end
    end
  end

   describe 'PATCH #update' do
     let!(:user) { FactoryBot.create(:user) }
     before do
       payload = { user_id: user.id }
       session = JWTSessions::Session.new(payload: payload)
       @tokens = session.login
     end

     # This part can be _ a lot _ DRYer. Improve later.
     context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }
      let(:new_info) { FactoryBot.build(:user) }

      context 'name' do
        before do
          request.headers[JWTSessions.access_header] = access_token
          patch :update, params: { name: new_info.name }
        end

        it do
          expect(response).to be_successful
          expect(response.body['name']).to eq( user.as_json['name'] )
        end
      end

      context 'email' do
        before do
          request.headers[JWTSessions.access_header] = access_token
          patch :update, params: { email: new_info.email }
        end

        it do
          expect(response).to be_successful
          expect(response.body['email']).to eq( user.as_json['email'] )
        end
      end

      context 'password' do
        before do
          request.headers[JWTSessions.access_header] = access_token
          patch :update, params: { password: new_info.password }
        end

        it do
          expect(response).to be_successful
          expect(response.body['password']).to eq( user.as_json['password'] )
        end
      end
     end

     context 'failure' do
       let!(:user_params) { {name: 'Placeholder'} }
       context 'no access token' do
         before { patch :update, params: user_params }

         it { expect(response.code).to eq '401' }
       end

       context 'no csrf token' do
         let(:access_token) { "Bearer #{@tokens[:access]}" }
         let(:access_cookie) { @tokens[:access] }
         let(:csrf_token) { @tokens[:csrf] }

         before do
           payload = { user_id: user.id }
           session = JWTSessions::Session.new(payload: payload)
           @tokens = session.login
         end

         it 'CSRF is not required for cookie-less based auth' do
           request.headers[JWTSessions.access_header] = access_token
           patch :update, params: user_params
           expect(response.code).to eq '200'
         end

         it do
           request.cookies[JWTSessions.access_cookie] = access_cookie
           patch :update, params: user_params
           expect(response.code).to eq '401'
         end
       end
     end
   end
 
#   describe 'DELETE #destroy' do
  # end
end
