require 'rails_helper'

describe Api::V1::ReportsController do

  describe 'GET' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }

      context 'get all reports' do
          let!(:reports_list) { FactoryBot.create_list(:report, 20) }
          before do
            request.headers[JWTSessions.access_header] = access_token
            get :index
          end

          it do
            expect(response).to be_successful
            expect(response_json.count).to eq(20)
          end
      end # end get all reports

      context 'show report' do
          let!(:instance) { FactoryBot.create(:report) }
          before do
            request.headers[JWTSessions.access_header] = access_token
            get :show, params: { id: instance.id }
          end

          it do
            expect(response).to be_successful
            expect(response_json['description']).to eql(instance.description)
          end
      end # end show report
    end

  end # end GET

  describe 'POST #create' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }
      let(:report_params) { { description: 'Description', lat: 9.99, lng: 9.99, user_id: user.id } }
      
      before do
        request.headers[JWTSessions.access_header] = access_token
        post :create, params: report_params
      end

      it 'should create a new report from parameters' do
        expect(response).to have_http_status(:created)
        expect(response_json[:description]).to eql(report_params['desc'])
        expect(response_json[:status]).to eql(report_params['new'])
      end
    end # end of success paths

    context 'failure' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }
      let(:report_params) { { lat: 9.99, lng: 9.99 } }
      
      before do
        request.headers[JWTSessions.access_header] = access_token
        get :create, params: report_params
      end

      it 'should not create' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end # end of failure paths

  end # end of POST #create

  describe 'PATCH #update' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }

      context 'updating description' do
        let!(:instance) { FactoryBot.create(:report) }
        let(:new_desc) { 'New Description' }

        before do
          request.headers[JWTSessions.access_header] = access_token
          patch :update, params: { id: instance.id, description: new_desc }
        end
        
        it 'should update description and status' do
          expect(response).to have_http_status(:ok)
          expect(response_json['description']).to eql(new_desc)
          expect(response_json['status']).to eql('edited')
        end
      end

      context 'adding response' do
        let!(:instance) { FactoryBot.create(:report) }
        let(:response_param) { 'A response' }

        before do
          request.headers[JWTSessions.access_header] = access_token
          patch :update, params: { id: instance.id, response: response_param }
        end
        
        it 'should add response and update status' do
          expect(response).to have_http_status(:ok)
          expect(response_json['response']).to eql(response_param)
          expect(response_json['status']).to eql('replied')
        end

      end

    end
  end # end of PATCH #update

  describe 'DELETE #destroy' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }
      let!(:instance) { FactoryBot.create(:report) }

      before do
        request.headers[JWTSessions.access_header] = access_token
        delete :destroy, params: { id: instance.id }
      end

      it 'should delete report' do
        expect(response).to have_http_status(:ok)
      end
    end # end of success paths

    context 'failure' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }

      before do
        request.headers[JWTSessions.access_header] = access_token
        delete :destroy, params: { id: 42 }
      end

      it 'should fail with bad request' do
        expect(response).to have_http_status(:not_found)
      end
    end # end of failing paths
  end # end of DELETE #destroy

  describe 'GET #index features' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'search by description' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }
      before do
        create_reports_from_desc_array(['simi', 'similar', 'not'])
        request.headers[JWTSessions.access_header] = access_token
        get :index, params: { description: 'simi' }
      end

      it do
        expect(response_json.count).to eq(2)
      end
    end

    context 'sort by creation date' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }

      context 'ascending/oldest' do
        before do
          create_reports_from_desc_array(['oldest', 'similar', 'newest'])
          request.headers[JWTSessions.access_header] = access_token
          get :index, params: { sort_by: 'creation', order:'asc' }
        end

        it 'should sort ascending and have pos'do
          expect(response).to have_http_status(:ok)
          json_arr = response_json
          last = JSON.parse json_arr.last

          expect(last['description']).not_to eq('oldest')
          expect(last).to have_key('pos')
        end
      end

      context 'descending/newest' do
        before do
          create_reports_from_desc_array(['oldest', 'similar', 'newest'])
          request.headers[JWTSessions.access_header] = access_token
          get :index, params: { sort_by: 'creation', order:'desc' }
        end

        it do
          expect(response).to have_http_status(:ok)
          json_arr = response_json
          first = JSON.parse json_arr.first

          expect(first['description']).not_to eq('oldest')
        end
      end

      context 'chain search and sort' do
        before do
          create_reports_from_desc_array(['only', 'onlymy', 'onlymyarray', 'not'])
          request.headers[JWTSessions.access_header] = access_token
          get :index, params: { description: 'only', sort_by: 'creation', order:'desc' }
        end
      
        it 'should have searched' do
          # Parse array of json
          r = JSON.parse response.body
          r = r.map { |i| JSON.parse i }
          expect(r.first['description']).not_to eq('only')
          descs = r.map{ |item| item['description'] }
          expect(descs).to contain_exactly('only', 'onlymy', 'onlymyarray')
        end
      end

    end

  end
end
