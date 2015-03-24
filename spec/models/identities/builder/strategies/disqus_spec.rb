require 'models/identities/builder_spec_helper'

describe Identities::Builder::Strategies::Disqus do

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      oauth_data = {
        "credentials" => {
          "token"=>"ba021c43208844f8868c9b818e737ca7",
          "refresh_token"=>"cdfc6c12de1d4b5a927d30690f712428",
          "expires_at"=>1429807763,
          "expires"=>true
        }
      }

      b = Identities::Builder::Strategies::Disqus.new(oauth_data)
      b.extract_credentials

      expect(b.result).to eq({
        credentials: {
          access_token: oauth_data.fetch('credentials').fetch('token'),
          refresh_token: oauth_data.fetch('credentials').fetch('refresh_token'),
          expires_at: oauth_data.fetch('credentials').fetch('expires_at')
        }
      })
    end
  end

  describe '#extract_forums' do
    it 'fetches the user\'s forums from the Disqus API' do
      b = Identities::Builder::Strategies::Disqus.new({'uid'=>32150332})

      VCR.use_cassette('builder_disqus_forums') do
        b.fetch_forums
      end

      expect(b.result).to include(:forums)
      expect(b.result[:forums].first).to include('id', 'name', 'url')
    end
  end

  describe 'refresh_credentials' do
    it 'refreshes the user\'s access tokens' do
      b = Identities::Builder::Strategies::Disqus.new({
        "credentials"=> {
          "token"=>"ba021c43208844f8868c9b818e737ca7",
          "refresh_token"=>"cdfc6c12de1d4b5a927d30690f712428",
          "expires_at"=>1429807763,
          "expires"=>true
        }
      })

      VCR.use_cassette('builder_disqus_refresh_credentials') do
        b.refresh_credentials
      end

      expect(b.result).to include(:credentials)
      expect(b.result[:credentials][:expires_at]).to > Time.now
    end
  end
end
