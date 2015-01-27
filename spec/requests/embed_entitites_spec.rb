require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before(:each) do
    post '/register/starter', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Account.find_by_email(AuthTestData::ACCOUNT_REGISTRATION_DATA[:email]).brands.first
  end

  context 'given the account is logged in and the brand is determined' do
    context 'and given a certain embed id' do

      describe 'GET /embed/1/entities' do
        it 'gets all entities belonging to an embed' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          link = embed.make_link_to(ent = FactoryGirl.create(:twitter_tweet))
          embed.make_link_to(ent = FactoryGirl.create(:github_issue))
          link.approve

          get "/api/#{api_version}/embeds/#{embed.id}/entities"
          expect(response).to be_success
          expect(json['data'].length).to eq(2)
        end
      end

      context 'when filtering by approved status' do
        before(:each) do
          @embed = FactoryGirl.create(:embed, brand: @current_brand)

          # approved by default
          @embed.make_link_to(ent = FactoryGirl.create(:github_watch))
          @embed.make_link_to(ent = FactoryGirl.create(:twitter_tweet)).disaprove
          @embed.make_link_to(ent = FactoryGirl.create(:github_issue)).disaprove
        end

        describe 'GET /embed/1/entities/approved' do
          it 'gets all approved entities belonging to an embed' do
            get "/api/#{api_version}/embeds/#{@embed.id}/entities/approved"
            expect(response).to be_success
            expect(json['data'].length).to eq(1)
          end
        end

        describe 'GET /embed/1/entities/waitlisted' do
          it 'gets all waitlisted entities belonging to an embed' do
            get "/api/#{api_version}/embeds/#{@embed.id}/entities/waitlisted"
            expect(response).to be_success
            expect(json['data'].length).to eq(2)
          end
        end
      end

      context 'when managing the approved status of individual entities' do
        before(:each) do
          @embed = FactoryGirl.create(:embed, brand: @current_brand)
          @link = @embed.make_link_to(@ent = FactoryGirl.create(:twitter_tweet))
        end

        describe 'PUT /embed/1/entities/2/approve' do
          context 'given a certain entity from an embed' do
            it 'approves it' do

              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@ent.id}/approve"
              expect(response).to be_success
              expect(json['is_approved']).to be_truthy
            end
          end
        end

        describe 'PUT /embed/1/entities/2/disaprove' do
          context 'given a certain entity from an embed' do
            it 'disaproves it' do
              @link.approve

              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@ent.id}/disaprove"
              expect(response).to be_success
              expect(json['is_approved']).to be_falsey
            end
          end
        end
      end
    end
  end
end
