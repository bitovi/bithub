require 'rails_helper'

RSpec.describe Api::HubsController, type: :controller do
	well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
	
	context "User is not authenticated" do
		describe "POST /hubs" do
			it "should require an authorized user to create a hub" do
				post :index, { organization_id: 1 }
				response.should have_http_status :unauthorized
			end
		end
		
		describe "GET /hubs" do
			it "should require an authorized user to get all hubs" do
				get :index
				response.should have_http_status :unauthorized
			end
		end
		
		describe "GET /hubs/:id" do
			it "should require an authorized user to get a single hub" do
				get :index, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
		
		describe "PUT /hubs/:id" do
			it "should require an authorized user to update a hub" do
				put :update, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
	
		describe "DELETE /hubs/:id" do
			it "should require an authorized user to delete an hub" do
				delete :destroy, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
	end
	
	context "User is authenticated" do
		before(:each) do
			@user = User.new(well_formed)
			@user.save!
		
			organization = Organizations::OrganizationBuilder.new @user, {}
			organization = organization.build.save!
			@organization = organization.organization
			
			sign_in :user, @user
		end
		
		describe "POST /hubs" do
			it "should require an organization_id to be provided" do
				post :create
				response.should have_http_status :bad_request
			end
			
			it "should generate a name if one is not provided" do
				post :create, { organization_id: @organization.id }
				response.should have_http_status :created
				body = JSON.parse(response.body)
				
				body["name"].should_not be_nil
			end
			
			it "should assign the provided name to the hub" do
				post :create, { organization_id: @organization.id, name: "HelloWorld" }
				response.should have_http_status :created
				body = JSON.parse(response.body)
				
				body["name"].should eq("HelloWorld")
			end

			it "should set approved_by_default to false if not provided" do
				post :create, { organization_id: @organization.id }
				body = JSON.parse(response.body)
				
				body["approved_by_default"].should eq(false)
			end
		end
		
		describe "GET /hubs/:id" do
			it "returns Not Found if the Hub requested is not found" do
				get :show, { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
			
			it "should return an Hub if the id provided is valid" do
				post :create, { organization_id: @organization.id, name: "HelloWorld" }
				id = JSON.parse(response.body)["id"]
				
				get :show, { id: id, organization_id: @organization.id }
				response.should have_http_status :ok

				JSON.parse(response.body)["data"]["name"].should eq("HelloWorld")
			end
		end
		
		describe "PUT /hubs/:id" do
			it "returns Not Found if Hub requested is not found" do
				put :update, { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
			
			it "returns Bad Request if the body contains an unknown attribute" do
				post :create, { organization_id: @organization.id }
				id = JSON.parse(response.body)["id"]
				
				put :update, { id: id, hub: { bad_attr: "OH NO!" }}
				response.should have_http_status :bad_request
			end
			
			it "should update the attributes" do
				post :create, { organization_id: @organization.id }
				id = JSON.parse(response.body)["id"]
				
				put :update, { id: id, hub: { name: "HelloWorld", approved_by_default: true }, organization_id: @organization.id}
				response.should have_http_status :ok
				body = JSON.parse(response.body)
				
				body["name"].should eq("HelloWorld")
				body["approved_by_default"].should eq(true)
			end
		end
		
		describe "DELETE /hubs/:id" do
			it "returns NotFound if the Hub request is not found" do
				get :show, { id: 999, organization_id: @organization.id }
				response.should have_http_status :not_found
			end
			
			it "should remove hub when found" do
				post :create, { organization_id: @organization.id }
				id = JSON.parse(response.body)["id"]
				
				delete :destroy, { id: id, organization_id: @organization.id }
				response.should have_http_status :ok
			end
		end
	end
end