require 'spec_helper'

describe "Events REST API" do
  before(:all) do
    @default_rule = create(:rule, required_tags: [], authorship_value: 0, upvote_value: 1, award_value: 0, priority: 0)
  end

  after(:all) do
    @default_rule.destroy
  end

  # ========> NOT LOGGED IN
  context "when there is no session" do

    # GET /api/events
    describe "GET /api/events" do
      context "without a query string" do
        it "should get all events, paginated and decorated" do
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

      context "with a query string" do
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

        it "should filter by regular params"
        it "should filter by date ranges"
        it "should filter by numeric ranges"
        it "should filter by negated attributes"
        it "should exclude attr on exclude query param"
      end
    end

    # GET /api/events/:id
    describe "GET /api/events/:id" do
      it "should respond with a JSON encoded event" do
        ev = create(:event_determined)
        get "/api/events/#{ev.id}"
        expect(response.body) =~ "many many words in it"
      end
    end

    # P0ST /api/events
    describe "POST /api/events" do
      it "should deny the event creation" do
        post "/api/events", event: { title: "Wassup?", body: "Nuthin' much." }
        expect(response.code).to eq("401")
      end
    end

    # PUT /api/events/:id
    describe "PUT /api/events/:id" do
      it "should deny the event updation" do
        put "/api/events/123", event: { title: "Wassup?", body: "Nuthin' much." }
        expect(response.code).to eq("401")
      end
    end
  end

  # ========> LOGGED IN
  context "when user is authenticated" do
    before :each do
      get_via_redirect "/api/auth/twitter"
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    # POST /api/events
    describe "POST /api/events" do
      it "should create a new event" do
        post "/api/events", :event => event_info
        expect(response.code).to eq("200")
      end
    end

    # PUT /api/events
    describe "PUT /api/events/:id" do
      it "should update an existing event" do
        event = create(:event_determined, title: "No title", body: "No body")
        put "/api/events/#{event.id}", event: event_info
        expect(response.code).to eq("200")
      end
    end
  end
end

def event_info
  {
    title: "Wassup?",
    body: "Nuthin' much.",
    feed: "github",
    category: "code",
    project: "canjs",
    tags: ["canjs", "donejs"]
  }
end
