require 'spec_helper'

describe "Users REST API" do

  # GET /api/users
  describe "GET /api/users" do
    context "without a query string" do
      it "should get all users, paginated and decorated" do
        user1 = create(:user)
        user2 = create(:user)
        get "/api/users"
        assigns(:users).should eq(UserDecorator.decorate_collection([user1, user2]))
      end

      it "should render the index template" do
        get "/api/users"
        expect(response).to render_template(:index)
      end
    end

    context "with a query string" do
      it "should ignore non-existent params" do
        user1 = create(:user)
        user2 = create(:user)
        get "/api/users", :some_param => "is not real"
        assigns(:users).should =~ UserDecorator.decorate_collection([user1, user2])
      end

      it "should filter by existing params" do
        user1 = create(:user, name: "Nikica Jokic", email: "neektza@gmail.com")
        user2 = create(:user, name: "Veljko Dragsic", email: "veljko.dragsic@gmail.com")
        get "/api/users", :name => "Nikica Jokic", email: "neektza@gmail.com"
        assigns(:users).should =~ UserDecorator.decorate_collection([user1])
      end

      it "should calculate score (a virtual attr) and order by it" do
        rule = create(:rule, authorship_value: 10, upvote_value: 3, award_value: 50)
        user1 = create(:user, name: "Nikica")
        user2 = create(:user, name: "Mihael")
        user3 = create(:user, name: "Veljko")
        event1 = create(:twitter_tweet, author: user1)
        event2 = create(:github_issue, author: user2)
        event3 = create(:forum_thread_starter, author: user2)
        users = User.select_with_score.order('total_score DESC').all
        get "/api/users", :order => "score:desc"
        assigns(:users).should eq UserDecorator.decorate_collection(users)
      end
    end
  end

  # GET /api/users/:id
  describe "GET /api/users/:id" do
    it "should respond with a JSON encoded user" do
      user = create(:user)
      get "/api/users/#{user.id}"
      assigns(:user).should eq(UserDecorator.decorate(user))
    end
  end

  # PUT /api/users/:id
  describe "PUT /api/users/:id" do
    before :each do
      get_via_redirect "/api/auth/twitter"
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
      request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it "should update a user" do
      user = create(:user, name: "Nikica")
      put "/api/users/#{user.id}", user: { name: "Kitica" }
      expect(user.reload.name).to eq "Kitica"
    end

    it "and respond with a JSON encoded, updated user" do
      user = create(:user, name: "Nikica")
      put "/api/users/#{user.id}", user: { name: "Kitica" }
      expect(response.body) =~ "Kitica"
    end
  end

end
