require 'rails_helper'
require_relative 'request_helpers'

SERVICE_POST_DATA = {
  feed_name: 'twitter',
  embed_id: 1
}

RSpec.describe 'Service creation', type: :request do
  let(:api_version) { 'v3' }
  before(:each) do
    post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
  end
  
  describe 'GET /services' do
    it 'gets all services for the current brand' do
      embed = FactoryGirl.create(:embed, brand: @current_brand)
      FactoryGirl.create(:service, embed: embed, feed_name: 'twitter')
      FactoryGirl.create(:service, embed: embed, feed_name: 'github')

      get '/api/v3/services'
      expect(json.length).to eq 2
    end
  end

  describe 'POST /services' do
    it 'creates a new service for the current brand' do
      get_via_redirect '/auth/twitter'
      e = FactoryGirl.create(:embed, brand: @current_brand)

      post '/api/v3/services', {
        service: {
          embed_id: e.id,
          feed_name: 'twitter'
        }
      }.to_json, AuthTestData::POST_HEADERS

      expect(Service.count).to eq 1
    end
  end

  describe 'DELETE /services/:id' do
    it 'destroys an existing service' do
      embed = FactoryGirl.create(:embed, brand: @current_brand)
      FactoryGirl.create(:service, embed: embed, feed_name: 'twitter')
      delete '/api/v3/services/1'
      expect(Service.count).to eq 0
    end
  end
end
