require 'models/identities/builder_spec_helper'

describe Identities::BuilderStrategies::Instagram do
  let(:oauth_data) do
    {
      "uid"=>"532573905",
      "credentials" => {
        "token"=>"532573905.045f29a.2553800ce44c4d2dbcfbc639eef56682",
        "expires"=>false
      }
    }
  end

  describe '#extract_credentials' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::BuilderStrategies::Instagram.new(oauth_data)
      b.extract_credentials

      expect(b.result).to eq({
        credentials: {
          access_token: oauth_data.fetch('credentials').fetch('token')
        }
      })
    end
  end
end
