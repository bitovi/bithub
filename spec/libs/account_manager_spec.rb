require 'spec_helper'

describe AccountManager, "creates/finds/syncs accounts" do
  let(:github_oauth_data) { oauth_data_hash['omniauth.auth'] }
  let(:twitter_oauth_data) { oauth_data_hash('twitter', 987654321, '', 'Nikica Jokic')['omniauth.auth']}

  describe ".find_or_create_identity" do
    it "delegates finding / creation of identity to the Identity model" do
      Identity.should_receive(:find_or_create_with_oauth_data)
      identity = AccountManager.find_or_create_identity(github_oauth_data)
    end
  end

  describe ".find_or_create_user" do
    it "gets the identity associated with oauth_data by delegating to .find_or_create identity" do
      AccountManager.should_receive(:find_or_create_identity)
      AccountManager.find_or_create_identity(github_oauth_data)
    end

    context "when user is already logged_in (current_user exists)" do
      it "assigns the found identity to the current_user if it isn't already" do
        user_with_only_gihub = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        user_with_only_gihub.save!

        user_with_both_idents = AccountManager.find_or_create_user('twitter', twitter_oauth_data, user_with_only_gihub)
        tw_ident = Identity.find_by_uid(twitter_oauth_data['uid'])
        gh_ident = Identity.find_by_uid(github_oauth_data['uid'])

        user_with_both_idents.identities.should =~ [tw_ident, gh_ident]
      end

      it "destroys the user possibly assigned to the found identity" do
        user_with_only_github = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        user_with_only_twitter = build(:user_with_twitter_ident, name: "Nikica Jokic")
        user_with_only_github.save! ; user_with_only_twitter.save!

        user_with_both_idents = AccountManager.find_or_create_user('twitter', twitter_oauth_data, user_with_only_github)
        non_existent_user = User.where(:id => user_with_only_twitter.id).first

        non_existent_user.should be_nil
      end
    end

    context "when user isn't logged in, but exists in the system" do
      it "finds the identity and returns the assigned user" do
        github_user = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        github_user.save!

        user = AccountManager.find_or_create_user('github', github_oauth_data)
        expect(user).to eq(github_user)
      end
    end

    context "when there is no user/identity present" do
      it "creates an identity and creates a user for that identity" do
        created_user = AccountManager.find_or_create_user('github', github_oauth_data)
        expected_identity = Identity.find_by_uid(github_oauth_data['uid'])
        expect(created_user).to eq(expected_identity.user)
      end
    end
  end

  describe ".pluck_data_for" do
    it "plucks [name, email] from oauth_data" do
      data = AccountManager.pluck_data_for('github', github_oauth_data)
      data.should =~ ['Nikica Jokic', 'neektza@gmail.com']
    end
  end
  
  describe ".name_from" do
    it "plucks a name from oauth_data" do
      name = AccountManager.name_from(github_oauth_data)
      expect(name).to eq("Nikica Jokic")
    end
  end
  
  describe ".email_from" do
    it "plucks an email from oauth_data" do
      email = AccountManager.email_from github_oauth_data
      expect(email).to eq("neektza@gmail.com")
    end
  end
end
