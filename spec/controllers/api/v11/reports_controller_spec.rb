require 'rails_helper'

describe Api::V11::ReportsController do

  describe 'GET' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload)
      @tokens = session.login
    end

    context 'success' do
      let(:access_token) { "Bearer #{@tokens[:access]}" }

      describe 'GET #index features' do

        let!(:user) { FactoryBot.create(:user) }
        before do
          payload = { user_id: user.id }
          session = JWTSessions::Session.new(payload: payload)
          @tokens = session.login
        end

        context 'pagination' do
          context 'record per limit is whole' do
            let!(:records) { 200 }
            # Default pagination limit
            # Notice that we don't pass it to params
            let!(:limit) { 50 }
            let(:pages) { records/limit }
            let!(:reports) { FactoryBot.create_list(:report,records) }

            before do
              request.headers[JWTSessions.access_header] = access_token
              get :index
            end

            it 'should return paginated results' do
              r = response_json
              expect(r.keys).to contain_exactly(*%w[page pages reports])
              expect(r['reports'].size).to eq(limit)
              expect(r['pages']).to eq(pages)
              # Should start at first page
              expect(r['page']).to eq(1)
            end
          end

          context 'requesting pages when record per limit is not whole' do
            let!(:remaining) { 1 }
            let!(:records) { 201 }
            let!(:limit) { 50 }
            let(:pages) { 1 + records/limit }
            let!(:reports) { FactoryBot.create_list(:report, 201) }

            before do
              request.headers[JWTSessions.access_header] = access_token
            end

            context 'last page' do
              it 'should return last page with remaining records' do
                                    # Last page
                get :index, params: { page: '5' }
                r = response_json
                expect(r['reports'].size).to eq(remaining)
                expect(r['pages']).to eq(pages)
                # Should be at last page
                expect(r['page']).to eq(pages)
              end
            end # context when sending last page end

            context 'middle page' do
              let!(:page) { 3 }
              it "should return page with 50 records" do
                                    # Last page
                get :index, params: { page: page }
                r = response_json
                expect(r['reports'].size).to eq(limit)
                expect(r['pages']).to eq(pages)
                # Should be at last page
                expect(r['page']).to eq(page)
              end
            end

            context 'out of bounds above page' do
              let!(:page) { pages + 1 }
              it "should return last page 1 record" do
                                    # Out of bounds page
                get :index, params: { page: page }
                r = response_json
                expect(r['reports'].size).to eq(remaining)
                expect(r['pages']).to eq(pages)
                # Should be at last page
                expect(r['page']).to eq(page - 1)
              end
            end

          end # context record per limit is not whole end 

          context 'sending custom limit' do
            let!(:records) { 201 }
            let!(:reports) { FactoryBot.create_list(:report, records) }
            let(:pages) { records/limit + (records%limit == 0 ? 0 : 1) }

            before do
              request.headers[JWTSessions.access_header] = access_token
              get :index, params: { limit: limit }
            end

            context 'below default' do
              let!(:limit) { 40 }

              it do 
                r = response_json

                expect(r['reports'].size).to eq(limit)
                expect(r['pages']).to eq(pages)
              end
            end

            context 'above default' do
              let!(:limit) { 60 }

              it do 
                r = response_json

                expect(r['reports'].size).to eq(limit)
                expect(r['pages']).to eq(pages)
              end

            end

            context 'non integer' do
              let!(:invalid_limit) { 'invalid' }
              # default
              let!(:limit) { 50 }

              it do 
                r = response_json

                expect(r['reports'].size).to eq(limit)
                expect(r['pages']).to eq(pages)
              end

            end
          end # end of sending custom limit

          context 'sending out of bounds  page' do
            let!(:reports) { FactoryBot.create_list(:report, 1) }

            before do
              request.headers[JWTSessions.access_header] = access_token
              get :index, params: { page: page }
            end

            context 'negative' do
              let!(:page) { -1 }

              it do 
                r = response_json
                expect(r['reports'].size).to eq(1)
                expect(r['pages']).to eq(1)
                expect(r['page']).to eq(1)
              end
            end

            context 'above' do
              let!(:page) { 2 }

              it do 
                r = response_json

                expect(r['reports'].size).to eq(1)
                expect(r['pages']).to eq(1)
                expect(r['page']).to eq(1)
              end

            end

          end

        end # context pagination end

        context 'search by description' do
          let(:access_token) { "Bearer #{@tokens[:access]}" }
          before do
            Report.all.destroy_all
            create_reports_from_desc_array(['simi', 'similar', 'not'])
            request.headers[JWTSessions.access_header] = access_token
            get :index, params: { description: 'simi' }
          end

          it do
            expect(response_json['reports'].size).to eq(2)
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
              last = response_json['reports'].last

              expect(last['description']).not_to eq('oldest')
              expect(last).to have_key('pos')
            end
          end

          context 'descending/newest' do
            before do
              Report.all.destroy_all
              create_reports_from_desc_array(['oldest', 'similar', 'newest'])
              request.headers[JWTSessions.access_header] = access_token
              get :index, params: { sort_by: 'creation', order:'desc' }
            end

            it do
              expect(response).to have_http_status(:ok)
              r = response_json
              first = r['reports'].first
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
              r = response_json['reports']
              expect(r.first['description']).not_to eq('only')
              descs = r.map{ |item| item['description'] }
              expect(descs).to contain_exactly('only', 'onlymy', 'onlymyarray')
            end
          end
        end # end of describe index features
      end
    end
  end
end
