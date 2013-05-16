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
      it "should ignore non-existent params"
      it "should filter by existing params"
      it "should calculate score (a virtual attr) and order by it"
    end
  end

  # GET /api/users/:id
  describe "GET /api/users/:id" do
    it "should respond with a JSON encoded user"
  end

  # POST /api/user
  describe "POST /api/users" do
    it "should create a new user"
    it "should respond with a JSON encoded, created user"
  end

  # PUT /api/users/:id
  describe "PUT /api/users/:id" do
    it "should update a user"
    it "and respond with a JSON encoded, updated user"
  end

end
