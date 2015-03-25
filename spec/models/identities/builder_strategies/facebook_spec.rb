require 'models/identities/builder_spec_helper'

describe Identities::BuilderStrategies::Facebook do

  let(:oauth_data) do
    { 
      "credentials" => {
        "token"=>"CAAKROn3HV5UBAMV92p4WY4VHk9PhNXaTtyLtvfxN6DdObrPZCAkhm71JZAilOVqBlYze8YuFapNoWXrsBlsGb2rKnXp88WEX6H713FrTlikq7wGwOSxsebq6RtD58MiyRRAjCUZA3EdhzXaJZBwbXd36GxP0uWw0oWYFddnak0sO6qy2TQs7WtyQbK0u7FjEfunomdw89QKq34CZCnHDW",
        "expires"=>true
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the user\'s regular token from OAuth data' do

      b = Identities::BuilderStrategies::Facebook.new(oauth_data)
      b.extract_credentials
      
      expect(b.result).to eq({
        credentials: { access_token: oauth_data.fetch('credentials').fetch('token') }
      })
    end
  end
  
  describe '#fetch_long_lived_access_token' do
    it 'fetches the user\'s long lived token from Facebook\'s OAuth API' do
      b = Identities::BuilderStrategies::Facebook.new(oauth_data)
      VCR.use_cassette('builder_facebook_long_lived_token') do
        b.fetch_long_lived_access_token
      end

      expect(b.result).to include(:credentials)
      expect(b.result[:credentials][:long_lived_access_token]).to be
    end
  end
  
  describe '#fetch_pages' do
    it 'fetches all user\'s pages from Facebook\s graph API' do
      b = Identities::BuilderStrategies::Facebook.new(oauth_data)

      VCR.use_cassette('builder_facebook_pages') do
        b.fetch_pages
      end

      expect(b.result).to include(:pages)
      expect(b.result[:pages].first).to include('id', 'name', 'access_token')
    end
  end
end
