require 'rails_helper'

RSpec.describe Api::ServicesController, type: :controller do	
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
			
			sign_in :user, @user
		end

		describe "POST /services" do
			it "should return 400 if missing hub_id" do
				post :create, { type_name: "site", feed_name: "rss", organization_id: @organization.id }
				response.should have_http_status :bad_request
			end

			it "should return 400 if missing type_name" do
				post :create, { hub_id: 1, feed_name: "rss", organization_id: @organization.id }
				response.should have_http_status :bad_request
			end

			it "should return 400 if missing feed_name or hub_idc" do
				post :create, { type_name: "site", organization_id: @organization.id }
				response.should have_http_status :bad_request
			end

			it "should return 400 if missing organization_id" do
				post :create, { hub_id: 1, type_name: "site", feed_name: "rss" }
				response.should have_http_status :bad_request
			end

			it "should have an id if created successfully" do
				post :create, { 
					organization_id: @organization.id,
					hub_id: 1, 
					type_name: "site", 
					feed_name: "rss",
					config: {
						url: "http://pltconfusion.com/rss.xml"
					}
				}
				response.should have_http_status :created
				JSON.parse(response.body)["id"].should_not be(nil)
			end
		end

		describe "GET /services" do
			it "should return 400 if missing organization_id" do
				get :index, { }
				response.should have_http_status :bad_request
			end
		end

		describe "DELETE /services/:id" do
			it "should return 400 if missing organization_id" do
				delete :destroy, { id: 1 }
				response.should have_http_status :bad_request
			end
			
			it "should return 404 if service id is not found" do
				delete :destroy,  { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
		end

		describe "PUT /services/:id" do
			it "should return 400 if missing organization_id" do
				put :update, { id: 1 }
				response.should have_http_status :bad_request
			end
			
			it "should return 404 if service id is not found" do
				put :update,  { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
		end
	end
end