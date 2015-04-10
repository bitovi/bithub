require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    post '/register/startup', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @embed = FactoryGirl.create(:embed, brand: Brand.current)
  end

  after do
    StripeMock.stop
  end

  context 'given the account is logged in and the brand is determined' do
    context 'and given a certain embed a filter belongs to' do

      describe 'GET /embeds/1/filters' do
        it 'gets all filters' do
          @embed.filters.create!(action: 'approve')
          @embed.filters.create!(action: 'block')

          get "/api/#{api_version}/embeds/#{@embed.id}/filters"
          expect(response).to be_success
          expect(json['data'].length).to eq(2)
        end
      end

      describe 'GET /embeds/1/filters/1' do
        it 'gets a specific filter' do
          f1 = @embed.filters.create(action: 'approve')
          @embed.filters.create(action: 'block')

          get "/api/#{api_version}/embeds/#{@embed.id}/filters/#{f1.id}"
          expect(response).to be_success
          expect(json.keys).to include('action')
        end
      end

      describe 'POST /embeds/1/filters/1' do
        context 'provided well defined filter data' do
          it 'creates a filter' do

            post "/api/#{api_version}/embeds/#{@embed.id}/filters", {
              filter: {
                action: 'approve',
                natlang_queries: [{
                  is_negated: false,
                  attr: 'content',
                  op: 'contains',
                  val: 'canjs'
                }, {
                  is_negated: true,
                  attr: '',
                  op: 'is',
                  val: 'canjs'
                }]
              }
            }.to_json, AuthTestData::POST_HEADERS

            expect(response).to be_success
            expect(json.keys).to include('action', 'queries')
          end
        end

        context 'provided ill defined filter data' do
          it 'refuses to create the filter' do
            post "/api/#{api_version}/embeds/#{@embed.id}/filters", {
              filter: {
                action: 'approve',
                natlang_queries: [{
                  is_negated: false,
                  attr: 'what',
                  op: 'even',
                  val: 'dat'
                }]
              }
            }.to_json, AuthTestData::POST_HEADERS

            expect(response).not_to be_success
          end
        end
      end

      describe 'DELETE /embeds/1/filters/2' do
        it 'destroys an existing filter' do
          filter = @embed.filters.create(action: 'approve')

          delete "/api/#{api_version}/embeds/#{@embed.id}/filters/#{filter.id}"
          expect(Filter.count).to eq 0
        end
      end
    end
  end
end
