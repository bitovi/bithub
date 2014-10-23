require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Brand endpoints', type: :request do
  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
    @current_brand = Brand.where(name: 'neektza').first
  end

  describe 'GET /brands/current' do
    it 'gets information about current brand' do
      get '/api/v2/brands/current'

      expect(response).to be_success
      expect(json['data']).to have_keys(%w(id name))
    end
  end
end
