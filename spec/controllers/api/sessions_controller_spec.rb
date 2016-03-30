require 'rails_helper'

RSpec.describe Api::SessionsController, type: :controller do
	describe "POST /session" do
		it "should return 400 when no email property is present" do
			post :create, { "password": "UDontKnowJack" }
			response.should have_http_status 400
		end
		
		it "should return 400 when no password property is present" do
			post :create, { "email": "hello@example.com" }
			response.should have_http_status 400
		end
		
		# it "should log a user in given an email and password" do
		# 	well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
		# 	Account.new(well_formed).save!
			
		# 	post :create, well_formed
		# 	response.should have_http_status 201
		# 	assigns[:current_account][:email].should eq("hello@example.com")
		# end
	end
	
	# describe "GET /session" do
	# 	it "should return a session when requested by an authenticated user" do
	# 		account = FactoryGirl.create(:account)
	# 		sign_in :account, account
	# 		get :show
	# 		response.should have_http_status 200
	# 		assigns[:current_account].should eq(account)
	# 	end
	# end
	
	describe "DELETE /session" do
		it "should log the user out when requested by an authenticated user" do
			sign_in :account, FactoryGirl.create(:account)
			delete :destroy
			response.should have_http_status 200
			assigns[:current_account].should be_nil
		end
	end
end
