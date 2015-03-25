require 'models/identities/builder_spec_helper'

describe Identities::BuilderStrategies::Foursquare do
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
      b = Identities::BuilderStrategies::Foursquare.new(oauth_data)
      b.extract_credentials

      expect(b.result).to eq({
        credentials: {
          access_token: oauth_data.fetch('credentials').fetch('token'),
        }
      })
    end
  end
  
  describe '#fetch_venues' do
    it 'fetches the user\'s managed venues from Foursquare\'s API' do
      b = Identities::BuilderStrategies::Foursquare.new(oauth_data)
      VCR.use_cassette('builder_foursquare_venues') do
        b.fetch_venues
      end

      expect(b.result).to include(:venues)
      expect(b.result[:venues].first).to include('id', 'name')
    end
  end
end
