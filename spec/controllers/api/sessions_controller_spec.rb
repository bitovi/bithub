require 'rails_helper'

RSpec.describe Api::SessionsController, type: :controller do
	well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
	
	describe "POST /session" do
		it "should return 400 when no email property is present" do
			post :create, { "password": "UDontKnowJack" }
			response.should have_http_status 400
		end
		
		it "should return 400 when no password property is present" do
			post :create, { "email": "hello@example.com" }
			response.should have_http_status 400
		end
	end
	
	context "the User exists in the system" do
		before(:each) do
			user = User.new(well_formed)
			user.save!
			
			organization = Organizations::OrganizationBuilder.new user, {}
			organization.build.save!
		end
		
		describe "POST /session" do
			it "should log an User in given an email and password" do
				post :create, well_formed
				response.should have_http_status 201
				get :index
				assigns[:current_user].email.should eq(well_formed[:email])
			end
		end
		
		describe "GET /session" do
			it "should return a session when requested by an authenticated User" do
				post :create, well_formed
				get :index
				response.should have_http_status 200
				assigns[:current_user].email.should eq(well_formed[:email])
			end
		end
	
		describe "DELETE /session" do
			it "should log the user out when requested by an authenticated User" do
				sign_in :user, FactoryGirl.create(:user)
				
				delete :destroy
				response.should have_http_status 200
				assigns[:current_user].should be_nil
			end
		end
	end
end
