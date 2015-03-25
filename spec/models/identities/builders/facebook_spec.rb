require 'models/identities/builder_spec_helper'

describe Identities::Builders::Facebook do

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
      b = Identities::Builders::Facebook.new(oauth_data)
      expect(b.credentials).to eq({
        access_token: oauth_data.fetch('credentials').fetch('token')
      })
    end
  end
  
  describe '#fetch_long_lived_access_token' do
    it 'fetches the user\'s long lived token from Facebook\'s OAuth API' do
      b = Identities::Builders::Facebook.new(oauth_data)
      VCR.use_cassette('builder_facebook_long_lived_token') do
        expect(b.long_lived_access_token).to be
      end
    end
  end
  
  describe '#fetch_pages' do
    it 'fetches all user\'s pages from Facebook\s graph API' do
      b = Identities::Builders::Facebook.new(oauth_data)
      VCR.use_cassette('builder_facebook_pages') do
        expect(b.pages.first).to include('id', 'name', 'access_token')
      end
    end
  end
end
