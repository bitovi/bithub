require 'models/identities/builder_spec_helper'

describe Identities::Builders::Foursquare do
  let(:oauth_data) do
    {
      "credentials" => {
        "token"=>"22PI511OSAJQDCUZT1JUAH3MIXCHCA24PJL04WPAB0HODUVM",
        "expires"=>false
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::Builders::Foursquare.new(oauth_data)
      expect(b.credentials).to eq({
        access_token: oauth_data.fetch('credentials').fetch('token')
      })
    end
  end

  describe '#fetch_venues' do
    it 'fetches the user\'s managed venues from Foursquare\'s API' do
      b = Identities::Builders::Foursquare.new(oauth_data)
      VCR.use_cassette('builder_foursquare_venues') do
        expect(b.venues.first).to include('id', 'name')
      end
    end
  end
end
