require 'rails_helper'

RSpec.describe Api::CredentialsController, type: :controller do
	well_formed = { "email": "hello@example.com", "password": "UDontKnowJack" }

	context "User is not authenticated" do
		describe "GET /credentials" do
			it "requires a user to be authenticated to get a list of credentials" do
				get :index
				response.should have_http_status :unauthorized
			end
		end

		describe "DELETE /credentials/:id" do
			it "requires a user to be authenticated to delete a credential" do
				delete :destroy, { id: 1 } 
				response.should have_http_status :unauthorized
			end
		end
	end

	context "User is authenticated." do
		before(:each) do
			@user = User.new(well_formed)
			@user.save!
		
			organization = Organizations::OrganizationBuilder.new @user, {}
			organization = organization.build.save!
			@organization = organization.organization
			@tenant = organization.brand.tenant_name
			@session = { organization_id: @organization.id, tenant_name: @tenant }
			
			sign_in :user, @user
		end

		context "No credentials have been created" do
			describe "GET /credentials" do
				it "returns a 200 and an empty array" do
					get :index, {}, @session
					response.should have_http_status 200
					JSON.parse(response.body).should eq []
				end
			end

			describe "DELETE /credentials/:id" do
				it "returns a 404 when trying to delete" do
					delete :destroy, { id: 999 }, @session
					response.should have_http_status 404
				end
			end
		end

		context "Credential(s) have been created" do
			before(:each) do
				FactoryGirl.create(:credential, provider: "facebook").save!
			end

			describe "GET /credentials" do
				it "returns a 200 and a populated array" do
					get :index, {}, @session
					response.should have_http_status 200
					JSON.parse(response.body).length.should be >= 0
				end
			end

			describe "DELETE /credentials/:id" do
				it "returns a 200 when successfully deleted" do
					delete :destroy, { id: Credential.all.first.id }, @session
					response.should have_http_status 200

					get :index, {}, @session
					JSON.parse(response.body).length.should eq 0
				end
			end
		end
	end
end