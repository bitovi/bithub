require 'spec_helper'

describe "Events REST API" do
  describe "GET index" do
    context "without params" do
      it "should get all events, decorated" do
        event = create(:event_determined)
        another_event = create(:event_determined)
        get "/api/events"
        assigns(:events).should eq(EventDecorator.decorate_collection([event, another_event]))
      end

      it "should render the index template" do
        get "/api/events"
        expect(response).to render_template(:index)
      end
    end
  end

  context "with arbitrary params" do
    it "should ignore non existend params" do
      create(:github_issue)
      create(:twitter_tweet)
      get "/api/events", :this_attr => "doesnt_exist"
      expect(assigns(:events).length).to eq(2)
    end

    it "should filter by feed" do
      create(:github_issue)
      create(:twitter_tweet)
      create(:forum_thread_starter)
      get "/api/events", :feed => "github"
      expect(assigns(:events).length).to eq(1)
    end

    it "should filter by category" do
      create(:github_issue)
      create(:github_issue_comment)
      create(:twitter_tweet)
      create(:forum_thread_starter)
      get "/api/events", :category => "bug"
      expect(assigns(:events).length).to eq(1)
    end

    it "should filter by any other tag" do
      create(:github_issue)
      create(:twitter_tweet)
      create(:forum_thread_starter)
      get "/api/events", :tag => "canjs"
      expect(assigns(:events).length).to eq(3)
    end

    it "should filter by combined tags" do
      create(:github_issue)
      create(:github_issue_comment)
      create(:github_push)
      create(:twitter_tweet)
      create(:forum_thread_starter)
      get "/api/events", :tag => "canjs", :feed => "github", :category => "code"
      expect(assigns(:events).length).to eq(1)
    end
  end
end
