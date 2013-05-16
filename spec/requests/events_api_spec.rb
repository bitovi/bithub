require 'spec_helper'

describe "Events REST API" do

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

      it "should filter by date ranges"
      it "should filter by numeric ranges"
    end

    # GET /api/events/:id
    describe "GET /api/events/:id" do
      it "should respond with a JSON encoded event"
    end

    # P0ST /api/events
    describe "POST /api/events" do
      context "user is not logged in" do
        it "should deny the event creation" do
          post "/api/events", event: {
            title: "Wassup?",
            body: "Nuthin' much."
          }
          expect(response.code).to eq("401")
        end
      end

      context "user is logged in" do
        before do
          get "/api/auth/twitter"
          request.env["devise.mapping"] = Devise.mappings[:user]
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        end

        it "should create a new event"
      end
    end

    # PUT /api/events/:id
    describe "PUT /api/events/:id" do
      context "user is not logged in" do
        it "should deny the event updation" do
          put "/api/events/123", event: {
            title: "Wassup?",
            body: "Nuthin' much."
          }
          expect(response.code).to eq("401")
        end
      end

      context "when user is logged in" do
        before do
          get "/api/auth/twitter"
          request.env["devise.mapping"] = Devise.mappings[:user]
          request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
        end

        it "should update an existing event"
      end
    end

  end
end
