require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Service endpoints', type: :request do
  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
    @current_brand = Brand.where(name: 'neektza').first
  end

  describe 'GET /brands/current/services' do
    it 'gets all services for the current brand'
  end
end
