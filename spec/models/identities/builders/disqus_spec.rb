require 'models/identities/builder_spec_helper'

describe Identities::Builders::Disqus do
  let(:oauth_data) do
    {
      'uid'=>32150332,
      "credentials" => {
        "token"=>"ba021c43208844f8868c9b818e737ca7",
        "refresh_token"=>"cdfc6c12de1d4b5a927d30690f712428",
        "expires_at"=>1429807763,
        "expires"=>true
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::Builders::Disqus.new(oauth_data)

      expect(b.credentials).to eq({
        access_token: oauth_data.fetch('credentials').fetch('token'),
        refresh_token: oauth_data.fetch('credentials').fetch('refresh_token'),
        expires_at: oauth_data.fetch('credentials').fetch('expires_at')
      })
    end
  end

  describe '#fetch_forums' do
    it 'fetches the user\'s forums from the Disqus API' do
      b = Identities::Builders::Disqus.new(oauth_data)

      VCR.use_cassette('builder_disqus_forums') do
        expect(b.forums.first).to include('id', 'name')
      end
    end
  end
end
