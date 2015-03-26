require 'models/identities/builder_spec_helper'

describe Identities::Builders::Twitter do
  let(:oauth_data) do
    {
      "uid"=>"532573905",
      "credentials" => {
        "token"=>"2613971238-9U5LMFsPxwR3kiP1QYFohBoHywbhYtwjM51dYyJ",
        "secret"=>"JPia4VY8A1He93HNX08GRS7nq26WNWbbwauQCTg6s7neI"
      }
    }
  end

  describe '#token' do
    it 'extracts the tokens from the OAuth response' do
      b = Identities::Builders::Twitter.new(oauth_data)
      expect(b.token).to eq(oauth_data.fetch('credentials').fetch('token'))
    end
  end
end
