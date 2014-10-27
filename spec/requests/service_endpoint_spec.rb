require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Service creation', type: :request do
  before(:each) do
    post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
  end

  describe 'GET /brands/current/services' do
    it 'gets all services for the current brand' do

      get_via_redirect '/auth/twitter'

      # stub_request(:get, "https://api.github.com/user/repos?per_page=100").
      #   with(:headers => {'Accept'=>'application/vnd.github.beta+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token mock_token', 'User-Agent'=>'Octokit Ruby Gem 2.7.2'}).
      #   to_return(:status => 200, :body => "", :headers => {})

      # stub_request(:get, "https://api.github.com/user/orgs").
      #    with(:headers => {'Accept'=>'application/vnd.github.beta+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'token mock_token', 'User-Agent'=>'Octokit Ruby Gem 2.7.2'}).
      #    to_return(:status => 200, :body => "", :headers => {})

      get_via_redirect '/auth/instagram'

      expect(BrandIdentity.count).to eq 2
    end
  end
end
