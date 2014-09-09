require 'domain/spec_helper'

RSpec.describe Accounts::AccountCreator, :type => :domain do

  # let(:github_oauth_data) { oauth_data_hash['omniauth.auth'] }
  # let(:twitter_oauth_data) { oauth_data_hash('twitter', 987654321, '', 'Nikica Jokic')['omniauth.auth']}

  describe "#create" do
    it "creates intializes and saves user along with assigning the identity to it"
    it "delegates creation of missing stars and repos to FakeDigestsCreator"
    it "invokes calculation of appropriate avatar_url"
    it "invokes point calculation for linking identities"
  end
end
