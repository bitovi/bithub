require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
	describe "POST /users" do
		it "should return 400 when no account property is present" do
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
		
		it "creates an account if the request is correctly formed" do
			post :create, well_formed_body
			response.should have_http_status 201
			Account.first.email.should eq "hello@example.com"
		end
		
		it "should return 422 if the email is already taken" do
			post :create, well_formed_body
			response.should have_http_status 201
			
			post :create, well_formed_body
			response.should have_http_status 422
		end
		
		it "creates an account with a organization, role, brand" do
			post :create, well_formed_body
			
			account = Account.first
			account.organizations.first.should be_a Organization
			account.roles.first.should be_a AccountRole
			account.brands.first.should be_a Brand
		end
		
		it "creates an account that is confirmed" do
			post :create, well_formed_body
			
			account = Account.first
			account.confirmation_sent_at.should_not be_nil
			account.confirmed_at.should_not be_nil
		end
		
		it "creates an account with a name if included" do
			well_formed_body[:name] = "Zack Attack"
			post :create, well_formed_body
			
			Account.first.name.should_not be_nil
			Account.first.name.should eq("Zack Attack")
		end
		
		it "names an organization if organization name is included" do
			well_formed_body[:organization] = { name: "TestOrg" }
			post :create, well_formed_body
			
			Account.first.organizations.first.name.should eq("TestOrg")
		end
	end
	
	describe "GET /users" do
		it "should require authentication to request accounts" do
			get :index
			response.should have_http_status 401
		end
		
		well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
		
		context "Account is signed in" do
			before(:example) do
				@account = Account.new(well_formed)
				@account.save!
			
				organization = Organizations::OrganizationBuilder.new @account, {}
				organization.build.save!
				
				sign_in :account, @account
			end
			
			it "should return a account object when authenticated" do
				get :index
				response.should have_http_status 200
				assigns(:current_account).should eq(@account)
			end
		end
	end
end
