require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    register_and_login
    @hub = FactoryGirl.create(:hub, brand: Brand.current)
  end

  after do
    StripeMock.stop
  end

  context 'given the user is logged in and the brand is determined' do
    context 'and given a certain hub a filter belongs to' do

      describe 'GET /hubs/1/filters' do
        # [TODO] FIX TEST
        # it 'gets all filters' do
        #   @hub.filters.create!(action: 'approve')
        #   @hub.filters.create!(action: 'block')

        #   get "/api/#{api_version}/hubs/#{@hub.id}/filters"
        #   expect(response).to be_success
        #   expect(json['data'].length).to eq(2)
        # end
      end

      describe 'GET /hubs/1/filters/1' do
        # [TODO] FIX TEST
        # it 'gets a specific filter' do
        #   f1 = @hub.filters.create(action: 'approve')
        #   @hub.filters.create(action: 'block')

        #   get "/api/#{api_version}/hubs/#{@hub.id}/filters/#{f1.id}"
        #   expect(response).to be_success
        #   expect(json.keys).to include('action')
        # end
      end

      describe 'POST /hubs/1/filters/1' do
        context 'provided well defined filter data' do
          # [TODO] FIX TEST
          # it 'creates a filter' do

          #   post "/api/#{api_version}/hubs/#{@hub.id}/filters", {
          #     filter: {
          #       action: 'approve',
          #       natlang_queries: [{
          #         is_negated: false,
          #         attr_name: 'content',
          #         op: 'contains',
          #         val: 'canjs'
          #       }, {
          #         is_negated: true,
          #         attr_name: '',
          #         op: 'is',
          #         val: 'canjs'
          #       }]
          #     }
          #   }.to_json, AuthTestData::POST_HEADERS

          #   expect(response).to be_success
          #   expect(json.keys).to include('action', 'natlang_queries')
          # end
        end

        context 'provided ill defined filter data' do
          it 'refuses to create the filter' do
            post "/api/#{api_version}/hubs/#{@hub.id}/filters", {
              filter: {
                action: 'approve',
                natlang_queries: [{
                  is_negated: false,
                  attr_name: 'what',
                  op: 'even',
                  val: 'dat'
                }]
              }
            }.to_json, AuthTestData::POST_HEADERS

            expect(response).not_to be_success
          end
        end
      end

      describe 'DELETE /hubs/1/filters/2' do
        # [TODO] FIX TEST
        # it 'destroys an existing filter' do
        #   filter = @hub.filters.create(action: 'approve')

        #   delete "/api/#{api_version}/hubs/#{@hub.id}/filters/#{filter.id}"
        #   expect(Filter.count).to eq 0
        # end
      end
    end
  end
end
