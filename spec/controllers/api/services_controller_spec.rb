require 'rails_helper'

RSpec.describe Api::ServicesController, type: :controller do
	rss_service_config = { hub_id: 1, feed_name: "rss", type_name: "site"}
	
	context "User is not authenticated" do
		describe "POST /services" do
			it "should require an authorized user to create a service" do
				get :create, { hub_id: 1, feed_name: "rss", type_name: "site"}
				response.should have_http_status :unauthorized
			end
		end
		
		describe "GET /services" do
			it "should require an authorized user to get all services" do
				get :index
				response.should have_http_status :unauthorized
			end
		end
		
		describe "PUT /services/:id" do
			it "should require an authorized user to update a service" do
				put :update, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end

		describe "DELETE /services/:id" do
			it "should require an authorized user to delete a service" do
				delete :destroy, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
	end

	context "User is authenticated" do
		before(:each) do
			@user = User.new({ "email": "hello@example.com", "password": "UDontKnowJack" })
			@user.save!
		
			organization = Organizations::OrganizationBuilder.new @user, {}
			organization = organization.build.save!
			@organization = organization.organization
			@tenant = organization.brand.tenant_name
			@session = { organization_id: @organization_id, tenant_name: @tenant }
			
			sign_in :user, @user
		end

		describe "POST /services" do
			it "should return 400 if missing hub_id" do
				post :create, { type_name: "site", feed_name: "rss" }, @session
				response.should have_http_status :bad_request
			end

			it "should return 400 if missing type_name" do
				post :create, { hub_id: 1, feed_name: "rss" }, @session
				response.should have_http_status :bad_request
			end

			it "should return 400 if missing feed_name" do
				post :create, { hub_id: 1, type_name: "site" }, @session
				response.should have_http_status :bad_request
			end
		end
	end
end