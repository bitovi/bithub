require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Brand endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    register_and_login
  end

  describe 'GET /brands/current' do
    it 'gets information about current brand' do
      get "/api/#{api_version}/brands/current"

      expect(response).to be_success
      expect(json.keys).to include('id', 'name', 'identities', 'tenant_name')
    end
  end

  describe 'POST and DELETE /brands' do
    it 'creates new brand and deletes it afterwards' do
      post "/api/#{api_version}/brands", { brand: AuthTestData::BRAND_DATA }.to_json, AuthTestData::POST_HEADERS

      expect(response).to be_success
      expect(json.keys).to include('id', 'name', 'identities', 'tenant_name')

      delete "/api/#{api_version}/brands/#{json['id']}"

      expect(response).to be_success
    end
  end

end
