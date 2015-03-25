require 'models/identities/builder_spec_helper'

describe Identities::BuilderStrategies::Meetup do
  let(:oauth_data) do
    {
      "uid"=>90485442,
      "credentials"=>{
        "token"=>"49d58f4a8082390d1ab61da05fd11ea8",
        "refresh_token"=>"f3fbcdde8d27554c8ea02facd52258e0",
        "expires_at"=>1427264292,
        "expires"=>true
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::BuilderStrategies::Meetup.new(oauth_data)
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
  
  describe '#fetch_groups' do
    it 'fetches the user\'s managed group from Meetup\'s API' do
      b = Identities::BuilderStrategies::Meetup.new(oauth_data)
      VCR.use_cassette('builder_meetup_groups') do
        b.fetch_groups
      end

      expect(b.result).to include(:groups)
      expect(b.result[:groups].first).to include(:id, :name, :urlname)
    end
  end
end
