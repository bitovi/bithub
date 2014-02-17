require 'domain/spec_helper'

describe Accounts::AccountManager do
  let(:github_oauth_data) { oauth_data_hash['omniauth.auth'] }
  let(:twitter_oauth_data) { oauth_data_hash('twitter', 987654321, '', 'Nikica Jokic')['omniauth.auth']}

  before :all do
    @default_rule = create(:rule)
  end

  after :all do
    @default_rule.destroy
  end

  describe ".find_or_create_user" do
    context "when user is already logged_in (current_user exists)" do

      it "should assign the found identity to the current_user if it isn't already"
      it "destroys the user possibly assigned to the found identity"
    end

    context "when user isn't logged in, but exists in the system" do
      it "should find the identity and return the assigned user" do
        github_user = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        github_user.save!

        user = AccountManager.new.find_or_create_user('github', github_oauth_data)
        expect(user).to eq(github_user)
      end
    end
  end

  describe "#create_missing_repos_and_watches!" do

    context "when logging in with github" do
      before :each do
        @am = AccountManager.new
        @am.stub_chain(:user_api, :watched_repos) { ApiResponses.watched_repos }
        @am.stub_chain(:identity, :uid) { 816489 }
        @am.stub_chain(:identity, :provider) { "github" }
        @am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
        @watching_repos = %w(bitovi/canjs bitovi/jquerypp bitovi/javascriptmvc)
      end

      it "should create missing watch_events"
      it "should not create watch_events that are already in the system"
    end

    context "when logging in with twitter" do
      before :each do
        @am = AccountManager.new
        @am.stub_chain(:user_api, :followed_accts) { ApiResponses.followed_accts }
        @am.stub_chain(:identity, :uid) { 55592490 }
        @am.stub_chain(:identity, :provider) { "twitter" }
        @am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
        @following_users = %w(canjs jquerypp javascriptmvc bitovi)
      end

      it "should create missing follow_events"      
      it "should not create follow_events that are already in the system"
    end
  end


  describe "#missing_repos" do
    it "should return repos that the user does not watch"
  end

  describe "#missing_friends" do
    it "should return repos that the user does not follow"
  end


  describe "#create_internal_watches" do
    it "should create a number of watch events" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 816489 }
      am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
      es = am.create_internal_watches!(ApiResponses.watched_repos)
      ex_es = Event.tagged_with('watch_event').all
      es.should =~ ex_es
    end

    it "should assign needed props to new events" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 816489 }
      am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
      es = am.create_internal_watches!(ApiResponses.watched_repos)
      es.first.props['origin_author_id'].should be
      es.first.props['origin_author_name'].should be
    end
  end

  describe "#create_internal_follows" do
    it "should create a number of follow events" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 55592490 }
      am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
      es = am.create_internal_follows!(ApiResponses.followed_accts)
      ex_es = Event.tagged_with('follow_event').all
      es.should =~ ex_es
    end

    it "should assign needed props to new events" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 55592490 }
      am.stub_chain(:identity, :source_data) { Hash.new({'nickname' => 'neektza'}) }
      es = am.create_internal_follows!(ApiResponses.followed_accts)

      es.first.props['origin_author_id'].should be
      es.first.props['origin_author_name'].should be
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

