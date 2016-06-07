require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
	describe "POST /users" do
		it "should return 400 when no user property is present" do
			post :create, { }
			response.should have_http_status 400
		end
		
		it "should return 400 when no email property is present" do
			post :create, { "password": "UDontKnowJack" }
			response.should have_http_status 400
		end
		
		it "should return 400 when no password property is present" do
			post :create, { "email": "hello@example.com" }
			response.should have_http_status 400
		end
		
		well_formed_body = { "email": "hello@example.com", "password": "UDontKnowJack" }
		
		it "creates an user if the request is correctly formed" do
			post :create, well_formed_body
			response.should have_http_status 201
			User.first.email.should eq "hello@example.com"
		end
		
		it "should return 422 if the email is already taken" do
			post :create, well_formed_body
			response.should have_http_status 201
			
			post :create, well_formed_body
			response.should have_http_status 422
		end
		
		it "creates an user with a organization, role, brand" do
			post :create, well_formed_body
			
			user = User.first
			user.organizations.first.should be_a Organization
			user.roles.first.should be_a UserRole
			user.brands.first.should be_a Brand
		end
		
		it "creates an user that is confirmed" do
			post :create, well_formed_body
			
			user = User.first
			user.confirmation_sent_at.should_not be_nil
			user.confirmed_at.should_not be_nil
		end
		
		it "creates an user with a name if included" do
			well_formed_body[:name] = "Zack Attack"
			post :create, well_formed_body
			
			User.first.name.should_not be_nil
			User.first.name.should eq("Zack Attack")
		end
		
		it "names an organization if organization name is included" do
			well_formed_body[:organization] = { name: "TestOrg" }
			post :create, well_formed_body
			
			User.first.organizations.first.name.should eq("TestOrg")
		end
	end
	
	describe "GET /users" do
		it "should require authentication to request users" do
			get :index
			response.should have_http_status 401
		end
		
		well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
		
		context "User is signed in" do
			before(:each) do
				@user = User.new(well_formed)
				@user.save!
			
				organization = Organizations::OrganizationBuilder.new @user, {}
				organization.build.save!
				
				sign_in :user, @user
			end
			
			it "should return a user object when authenticated" do
				get :index
				response.should have_http_status 200
				assigns(:current_user).should eq(@user)
			end
		end
	end
end
