require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Brand endpoints', type: :request do
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
    @current_brand = Account.find_by_email(AuthTestData::ACCOUNT_REGISTRATION_DATA[:email]).brands.first
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
