require 'spec_helper'

describe "Users REST API" do
  describe "GET index" do
    context "without params" do
      it "should get all users, decorated" do
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
  end

  context "with arbitrary params"
end
