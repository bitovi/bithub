require 'models/identities/builder_spec_helper'

describe Identities::Builders::Instagram do
  let(:oauth_data) do
    {
      "uid"=>"532573905",
      "credentials" => {
        "token"=>"532573905.045f29a.2553800ce44c4d2dbcfbc639eef56682",
        "expires"=>false
      }
    }
  end

  describe '#token' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::Builders::Instagram.new(oauth_data)
      expect(b.token).to eq(oauth_data.fetch('credentials').fetch('token'))
    end
  end
end
