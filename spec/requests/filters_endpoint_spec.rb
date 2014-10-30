require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  before(:each) do
    post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
  end

  describe 'GET /filters' do
    it 'gets all filters for current brand'
  end

  describe 'POST /filters' do
    it 'creates a filter for the current brand'
  end
end

