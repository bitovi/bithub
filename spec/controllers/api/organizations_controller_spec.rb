require 'rails_helper'

RSpec.describe Api::OrganizationsController, type: :controller do
	well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }
	
	context "User is not authenticated" do
		describe "GET /organizations" do
			it "should require an authorized user to get all organizations" do
				get :index
				response.should have_http_status :unauthorized
			end
		end
		
		describe "GET /organizations/:id" do
			it "should require an authorized user to get a single organizations" do
				get :index, { id: 1 }
				response.should have_http_status :unauthorized
			end
		end
		
		describe "PUT /hubs/:id" do
			it "should require an authorized user to update an organization" do
				put :update, { id: 1 }
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
		
		describe "GET /organizations/:id" do
			it "returns Not Found if the Organization requested is not found" do
				get :show, { id: 999 }
				response.should have_http_status :not_found
			end
			
			it "should return an Organization if the id provided is valid" do
				get :show, { id: @organization.id }, @session
				id = JSON.parse(response.body)["id"]
				response.should have_http_status :ok
			end
		end
		
		describe "PUT /hub/:id" do
			it "returns Not Found if Organization requested is not found" do
				put :update, { id: 999 }, @session
				response.should have_http_status :not_found
			end
			
			it "returns Bad Request if the body contains an unknown attribute" do				
				put :update, { id: @organization.id, organization: { bad_attr: "OH NO!" }}, @session
				response.should have_http_status :bad_request
			end
			
			it "should update the attributes" do				
				put :update, { id: @organization.id, organization: { name: "HelloWorld" }}, @session
				response.should have_http_status :ok
				JSON.parse(response.body)["name"].should eq("HelloWorld")
			end
		end
	end
end