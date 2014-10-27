require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Brand endpoints', type: :request do

  before(:each) do
    post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
  end

  let(:api_version) { 'v3' }

  describe 'GET /brands/current' do
    it 'gets information about current brand' do
      get "/api/#{api_version}/brands/current"

      expect(response).to be_success
      expect(json['data'].keys).to include('id', 'name', 'identities', 'tenant_name')
    end
  end

  describe 'POST and DELETE /brands' do
    it 'creates new brand and deletes it afterwards' do
      post "/api/#{api_version}/brands", { brand: brand_data }.to_json, post_headers

      expect(response).to be_success
      expect(json['data'].keys).to include('id', 'name', 'identities', 'tenant_name')

      delete "/api/#{api_version}/brands/#{json['data']['id']}"

      expect(response).to be_success
    end
  end

end
