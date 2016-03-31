require 'rails_helper'

RSpec.describe Api::AccountsController, type: :controller do
	describe "POST /accounts" do
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
	end
	
	describe "GET /accounts" do
		it "should require authentication to request accounts" do
			get :index
			response.should have_http_status 401
		end
		
		it "should return a account object when authenticated" do
			account = FactoryGirl.create(:account)
			sign_in :account, account
			get :index
			response.should have_http_status 200
			assigns[:current_account].should eq(account)
		end
	end
end
