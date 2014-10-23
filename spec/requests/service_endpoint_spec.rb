require 'rails_helper'

RSpec.describe 'Service creation', type: :request do
  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
  end

  describe 'GET /brands/current/services' do
    it 'gets all services for the current brand' do
      account_data = { email: 'neektza@gmail.com', password: 'foobar123' }

      post '/register', { account: account_data.merge({password_confirmation: 'foobar123'}) }
      post '/login', { account: account_data.merge({remember_me: 0}) }
      get '/auth/github'
      get '/auth/twitter'

      pending('TODO')
    end
  end
end
