require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    StripeMock.start
    StripeMock.create_test_helper.create_plan(id: 'starter', amount: 1000, trial_period_days: 45)
  end
  after do
    StripeMock.stop
  end

  before(:each) do
    post "/register/starter", { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
  end

  context 'given the account is logged in and the brand is determined' do
    context 'and given a certain embed the filter belongs to' do

      describe 'GET /embed/1/filters' do
        it 'gets all filters' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          embed.filters.create!(classification: 'moderating')
          embed.filters.create!(classification: 'blocking')

          get "/api/#{api_version}/embeds/#{embed.id}/filters"
          expect(response).to be_success
          expect(json['data'].length).to eq(2)
        end
      end

      describe 'GET /embeds/1/filters/1' do
        it 'gets a specific filter' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          embed.filters.create(classification: 'moderating')
          embed.filters.create(classification: 'blocking')

          get "/api/#{api_version}/embeds/#{embed.id}/filters/1"
          expect(response).to be_success
          expect(json.keys).to include('is_conj', 'classification')
        end
      end

      describe 'POST /embeds/1/filters' do
        context 'provided well defined filter data' do
          it 'creates a filter' do
            embed = FactoryGirl.create(:embed, brand: @current_brand)

            post "/api/#{api_version}/embeds/#{embed.id}/filters", {
              filter: {
                is_conj: true,
                classification: 'moderating',
                natlang_queries: [{
                  is_negated: false,
                  attr: 'content',
                  op: 'contains',
                  val: 'canjs'
                }, {
                  is_negated: true,
                  attr: '',
                  op: 'tagged_with',
                  val: 'canjs'
                }]
              }
            }.to_json, AuthTestData::POST_HEADERS

            expect(response).to be_success
            expect(json.keys).to include('is_conj', 'classification', 'queries')
          end
        end

        context 'provided ill defined filter data' do
          it 'refuses to create the filter' do
            embed = FactoryGirl.create(:embed, brand: @current_brand)

            post "/api/#{api_version}/embeds/#{embed.id}/filters", {
              filter: {
                is_conj: true,
                classification: 'moderating',
                natlang_queries: [{
                  is_negated: false,
                  attr: 'is',
                  op: 'wat',
                  val: 'dat'
                }]
              }
            }.to_json, AuthTestData::POST_HEADERS

            expect(response).not_to be_success
          end
        end
      end

      describe 'DELETE /filters/:id' do
        it 'destroys an existing embed' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          filter = embed.filters.create(classification: 'moderating')

          delete "/api/#{api_version}/embeds/#{embed.id}/filters/#{filter.id}"
          expect(Filter.count).to eq 0
        end
      end
    end
  end
end
