require 'rails_helper'
require_relative 'request_helpers'

SERVICE_POST_DATA = {
  feed_name: 'twitter',
  embed_id: 1
}

RSpec.describe 'Service creation', type: :request do
  let(:api_version) { 'v3' }

  before do
    StripeMock.start
    StripeMock.create_test_helper.create_plan(id: 'starter', amount: 1000, trial_period_days: 45)
  end
  after do
    StripeMock.stop
  end

  before(:each) do
    post '/register/starter', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
    @embed = FactoryGirl.create(:embed, brand: @current_brand)
    get_via_redirect '/auth/twitter'
  end

  context 'given the account is logged in and the brand is determined' do
    describe 'GET /embed/1/services' do
      it 'gets all services' do
        FactoryGirl.create(:twitter_service, embed: @embed)
        FactoryGirl.create(:twitter_service, embed: @embed)

        get "/api/#{api_version}/embeds/#{@embed.id}/services"
        expect(json.length).to eq 2
      end
    end

    describe 'GET /embed/1/services/1' do
      it 'gets a specific service' do
        s = FactoryGirl.create(:twitter_service, embed: @embed)

        get "/api/#{api_version}/embeds/#{@embed.id}/services/#{s.id}"
        expect(json.keys).to include('feed_name', 'type_name', 'config')
      end
    end

    describe 'POST /services' do
      context 'given well defined service data' do
        it 'creates a new service' do

          post "/api/#{api_version}/embeds/#{@embed.id}/services", {
            service: {
              feed_name: 'twitter',
              type_name: 'user_timeline',
              config: {
                :terms => %w(@canjs)
              }
            }
          }.to_json, AuthTestData::POST_HEADERS

          expect(response).to be_success
          expect(Service.count).to eq 1
        end
      end

      context 'provided ill defined service data' do
        it 'refuses to create a service' do

          post "/api/#{api_version}/embeds/#{@embed.id}/services", {
            service: {
              feed_name: 'foosbal',
              type_name: 'nonexistent',
              config: {
                terms: %w(wat are these)
              }
            }
          }.to_json, AuthTestData::POST_HEADERS

          expect(response).not_to be_success
        end
      end
    end

    describe 'DELETE /embed_services/1' do
      it 'destroys an existing service' do
        s = FactoryGirl.create(:twitter_service, embed: @embed)
        delete "/api/#{api_version}/embeds/#{@embed.id}/services/#{s.id}"
        expect(Service.count).to eq 0
      end
    end
  end
end
