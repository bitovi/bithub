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
			it "should require an authorized user to delete an embed" do
				delete :destroy, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
	end
	
	context "User is authenticated" do
		before(:example) do
			@account = Account.new(well_formed)
			@account.save!
		
			organization = Organizations::OrganizationBuilder.new @account, {}
			organization = organization.build.save!
			@organization = organization.organization
			@tenant = organization.brand.tenant_name
			@session = { organization_id: @organization_id, tenant_name: @tenant }
			
			sign_in :account, @account
		end
		
		describe "POST /hubs" do
			it "should require an organization_id to be provided" do
				post :create
				response.should have_http_status :bad_request
			end
			
			it "should require generate a name if one is not provided" do
				post :create, { organization_id: @organization.id }, @session
				response.should have_http_status :created
				body = JSON.parse(response.body)
				
				body["name"].should_not be_nil
			end
			
			it "should assign the provided name to the embed" do
				post :create, { organization_id: @organization.id, name: "HelloWorld" }, @session
				response.should have_http_status :created
				body = JSON.parse(response.body)
				
				body["name"].should eq("HelloWorld")
			end
		end
		
		describe "GET /hubs/:id" do
			it "returns NotFound if the Embed requested is not found" do
				get :show, { id: 999 }
				response.should have_http_status :not_found
			end
			
			it "should return an Embed if the id provided is valid" do
				post :create, { organization_id: @organization.id, name: "HelloWorld" }, @session
				id = JSON.parse(response.body)["id"]
				
				get :show, { id: id }, @session
				response.should have_http_status :ok
				JSON.parse(response.body)["name"].should eq("HelloWorld")
			end
		end
		
		describe "PUT /hub/:id" do
			
		end
		
		describe "DELETE /hub/:id" do
			it "returns NotFound if the Embed request is not found" do
				get :show, { id: 999 }, @session
				response.should have_http_status :not_found
			end
			
			it "should remove embed when found" do
				post :create, { organization_id: @organization.id }, @session
				id = JSON.parse(response.body)["id"]
				
				delete :destroy, { id: id }, @session
				response.should have_http_status :ok
			end
		end
	end
end