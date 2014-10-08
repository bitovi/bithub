require 'rails_helper'

describe Accounts::AccountManager, :type => :domain do
  describe "#only_logging_in?" do
    it "says we're only logging in if there's no current_user" do
      identity = FactoryGirl.build(:identity, :from_twitter)
      am = Accounts::AccountManager.new(:twitter, identity, nil)
      expect(am.only_logging_in?).to be_truthy
    end
  end
  

  describe "#linking_or_merging?" do
    it "says we're linking_or_merging if the provided identity is already associated with the current_user" do
      current_user = FactoryGirl.build(:user, :with_github_ident)
      identity = FactoryGirl.build(:identity, :from_twitter)

      am = Accounts::AccountManager.new(:twitter, identity, current_user)
      expect(am.linking_or_merging?).to be_truthy
    end
  end
end
