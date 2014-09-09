require 'domain/spec_helper'

RSpec.describe Accounts::AccountLinker, :type => :domain do
  
  describe "#determine_state" do

    before :each do
      @nikica = FactoryGirl.create(:user, name: 'Nikica', email: 'neektza@gmail.com')
      @veljko = FactoryGirl.create(:user, name: 'Veljko', email: 'veljko@kset.org')
    end

    context "linking with a new, unclaimed identity" do
      it "should claim the identity to the existing user" do
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter')

        al = Accounts::AccountLinker.new(@nikica, identity_twitter)
        expect(al.determine_state.state).to eq :only_linking
      end
    end

    context "linking with a claimed identity whose user has no more identities assigned" do
      it "should claim that identity and merge users into one user" do
        identity_github = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @veljko)

        al = Accounts::AccountLinker.new(@nikica, identity_twitter)
        expect(al.determine_state.state).to eq :valid_merge
      end
    end

    context "when there is already another user that owns the identity being merged and has an identity of same provider" do
      it "should destroy the other user and snatches it's identity" do
        identity_github_n = create(:identity, uid: 987654321, provider: 'github', user: @nikica)
        identity_twitter = create(:identity, uid: 123456789, provider: 'twitter', user: @nikica)

        identity_github_v = create(:identity, uid: 12849234, provider: 'github', user: @veljko)
        identity_meetup = create(:identity, uid: 456712345, provider: 'meethup', user: @veljko)

        al = Accounts::AccountLinker.new(@nikica, identity_meetup)
        expect(al.determine_state.state).to eq :invalid_merge
      end
    end
  end
end
