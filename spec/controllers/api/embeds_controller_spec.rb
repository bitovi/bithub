require "rails_helper"

RSpec.describe Api::EmbedsController, type: :controller do
	context "User is not authenticated" do
		describe "POST /embeds" do
			it "should require an authorized user to create a service" do
				get :create, { hub_id: 1 }
				response.should have_http_status :unauthorized
			end
		end
		
		describe "GET /embeds" do
			it "should require an authorized user to get all services" do
				get :index
				response.should have_http_status :unauthorized
			end
		end
		
		describe "PUT /embeds/:id" do
			it "should require an authorized user to update a service" do
				put :update, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end

		describe "DELETE /embeds/:id" do
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

			Apartment::Tenant.switch!(@tenant)

			@hub = FactoryGirl.create(:hub)
			@hub.save!
		end

		after(:each) do
			Apartment::Tenant.switch!
		end

		describe "POST /embeds" do
			it "should return 400 if missing hub_id" do
				post :create, { organization_id: @organization.id }
				response.should have_http_status :bad_request
			end

			it "should fail to create an embed when hub_id does not exist" do
				post :create, { 
					organization_id: @organization.id,
					hub_id: 999
				}
				response.should have_http_status :bad_request
			end

			it "should have an id if created successfully" do			
				post :create, { 
					organization_id: @organization.id,
					hub_id: @hub.id
				}
				response.should have_http_status :created
				JSON.parse(response.body)["id"].should_not be(nil)
			end
		end

		describe "GET /embeds" do
			it "should return 400 if missing organization_id" do
				get :index, { }
				response.should have_http_status :bad_request
			end
		end

		describe "DELETE /embeds/:id" do
			it "should return 400 if missing organization_id" do
				delete :destroy, { id: 1 }
				response.should have_http_status :bad_request
			end
			
			it "should return 404 if service id is not found" do
				delete :destroy,  { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
		end

		describe "PUT /embeds/:id" do
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