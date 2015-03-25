require 'models/identities/builder_spec_helper'

describe Identities::Builder::Strategies::Github do
  let(:oauth_data) do
    {
      "credentials"=>{
        "token"=>"67d6bf9862995f2c354a30eb8d22727e079a8c51",
        "expires"=>false
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::Builder::Strategies::Github.new(oauth_data)
      b.extract_credentials

      expect(b.result).to eq({
        credentials: {
          access_token: oauth_data.fetch('credentials').fetch('token'),
        }
      })
    end
  end
  
  describe '#fetch_repos' do
    it 'fetches the user\'s owned repos from Github\'s API' do
      b = Identities::Builder::Strategies::Github.new(oauth_data)
      VCR.use_cassette('builder_github_repos') do
        b.fetch_repos
      end

      expect(b.result).to include(:repos)
      expect(b.result[:repos].first).to include(:id, :name)
    end
  end
end
