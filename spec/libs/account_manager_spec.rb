require 'spec_helper'
require Rails.root + 'spec/libs/api_responses'

describe AccountManager, "creates/finds/syncs accounts" do
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

      it "should assign the found identity to the current_user if it isn't already" do
        user_with_only_github = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        user_with_only_github.save!

        @am = AccountManager.new(user_with_only_github)
        @am.stub_chain(:user_api, :watched_repos) { ApiResponses.watched_repos }
        user_with_both_idents = @am.find_or_create_user('twitter', twitter_oauth_data)

        tw_ident = Identity.find_by_uid(twitter_oauth_data['uid'])
        gh_ident = Identity.find_by_uid(github_oauth_data['uid'])

        user_with_both_idents.identities.should =~ [tw_ident, gh_ident]
      end

      it "destroys the user possibly assigned to the found identity" do
        user_with_only_github = build(:user_with_github_ident, name: "Nikica Jokic", email: "neektza@gmail.com")
        user_with_only_twitter = build(:user_with_twitter_ident, name: "Nikica Jokic")
        user_with_only_github.save!
        user_with_only_twitter.save!

        @am = AccountManager.new(user_with_only_github)
        @am.stub_chain(:user_api, :followed_accts) { ApiResponses.followed_accts }
        user_with_both_idents = @am.find_or_create_user('twitter', twitter_oauth_data)

        non_existent_user = User.where(:id => user_with_only_twitter.id).first

        non_existent_user.should be_nil
      end
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
        @watching_repos = %w(bitovi/canjs bitovi/jquerypp bitovi/javascriptmvc)
      end

      it "should check" do
        @am.create_missing_repos_and_watches!
        Event.tagged_with('watch_event').count.should == @watching_repos.length
      end

      it "should also" do
        create(:github_watch_event, props: {origin_author_id: '816489', repo: 'bitovi/canjs'})
        @am.create_missing_repos_and_watches!
        Event.tagged_with('watch_event').count.should == @watching_repos.length - 1
      end
    end

    context "when logging in with twitter" do
      before :each do
        @am = AccountManager.new
        @am.stub_chain(:user_api, :followed_accts) { ApiResponses.followed_accts }
        @am.stub_chain(:identity, :uid) { 55592490 }
        @am.stub_chain(:identity, :provider) { "twitter" }
        @following_users = %w(canjs jquerypp javascriptmvc bitovi)
      end

      it "should check" do
        @am.create_missing_repos_and_watches!
        Event.tagged_with('follow_event').count.should == @following_users.length
      end
      
      it "should also" do
        create(:twitter_follow_event, props: {origin_author_id: '55592490', target: 'canjs'})
        @am.create_missing_repos_and_watches!
        Event.tagged_with('follow_event').count.should == @following_users.length - 1
      end
    end
  end


  describe "#missing_repos" do
    it "should return repos that the user does not follow" do
      am = AccountManager.new
      am.stub_chain(:user_api, :watched_repos) { ApiResponses.watched_repos }
      am.stub_chain(:identity, :uid) { 816489 }

      create(:github_watch_event,
             props: { origin_author_id: 816489 },
             source_data: { repo: { full_name: 'bitovi/canjs' }})

      mrs = am.missing_repos

      mrs.should =~ ApiResponses.watched_repos.select{|r| %w(bitovi/jquerypp bitovi/javascriptmvc).include? r['full_name']}
    end
  end

  describe "#missing_friends" do
    it "should return repos that the user does not follow" do
      am = AccountManager.new
      am.stub_chain(:user_api, :followed_accts) { ApiResponses.followed_accts }
      am.stub_chain(:identity, :uid) { 55592490 }

      create(:twitter_event, :follow_event,
             props: { origin_author_id: 55592490 },
             source_data: { target: { screen_name: 'canjs' }})

      mfs = am.missing_friends

      mfs.should =~ ApiResponses.followed_accts.select{|a| %w(jquerypp javascriptmvc bitovi).include?(a['screen_name'] || a[:screen_name])}
    end
  end


  describe "#create_internal_watches" do
    it "should create a follow_event" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 816489 }

      es = am.create_internal_watches!(ApiResponses.watched_repos)
      ex_es = Event.tagged_with('watch_event').all

      es.should =~ ex_es
    end
  end

  describe "#create_internal_follows" do
    it "should create a follow_events" do
      am = AccountManager.new
      am.stub_chain(:identity, :uid) { 55592490 }

      es = am.create_internal_follows!(ApiResponses.followed_accts)
      ex_es = Event.tagged_with('follow_event').all

      es.should =~ ex_es
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

