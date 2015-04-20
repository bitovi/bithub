require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    post '/register/startup', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
  end

  context 'given a certain embed id' do
    context 'assuming the request requires admin privileges' do
      context 'and the user is managing the state of individual entities' do

        before do
          @embed = FactoryGirl.create(:embed, brand: Brand.current)
          @entity = FactoryGirl.create(:twitter_tweet)
          @embed.make_link_to(@entity)
        end

        describe 'PUT /embed/1/entities/2/approve' do
          context 'given a certain entity from an embed' do
            it 'approves it' do

              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@entity.id}/approve"
              expect(response).to be_success
              expect(json['is_approved']).to be_truthy
            end
          end
        end

        describe 'PUT /embed/1/entities/2/disapprove' do
          context 'given a certain entity from an embed' do
            it 'disaproves it' do
              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@entity.id}/disapprove"
              expect(response).to be_success
              expect(json['is_approved']).to be_falsey
            end
          end
        end

        describe 'PUT /embed/1/entities/2/pin' do
          context 'given a certain entity from an embed' do
            it 'pins it to the top' do
              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@entity.id}/pin"
              expect(response).to be_success
              expect(json['is_pinned']).to be_truthy
            end
          end
        end

        describe 'PUT /embed/1/entities/2/unpin' do
          context 'given a certain entity from an embed' do
            it 'unpins it from the top' do
              put "/api/#{api_version}/embeds/#{@embed.id}/entities/#{@entity.id}/unpin"
              expect(response).to be_success
              expect(json['is_pinned']).to be_falsey
            end
          end
        end
      end
    end

    context 'assuming the request is public' do
      describe 'GET /embed/1/entities' do
        context 'when the embed is blocking and there are no filters' do
          it 'respondwith an empty array' do
            embed = FactoryGirl.create(:embed, brand: Brand.current, approved_by_default: false)
            embed.make_link_to(FactoryGirl.create(:github_watch))
            embed.make_link_to(FactoryGirl.create(:twitter_tweet))

            get "/api/#{api_version}/embeds/#{embed.id}/entities?tenant_name=#{Brand.current.name}"
            expect(response).to be_success
            expect(json['data'].length).to eq(0)
          end
        end

        context 'when the embed is approving and there are no filters' do
          it 'respond with an empty array' do
            embed = FactoryGirl.create(:embed, brand: Brand.current, approved_by_default: true)
            embed.make_link_to(FactoryGirl.create(:github_watch))
            embed.make_link_to(FactoryGirl.create(:github_issue))
            
            get "/api/#{api_version}/embeds/#{embed.id}/entities?tenant_name=#{Brand.current.name}"
            expect(response).to be_success
            expect(json['data'].length).to eq(2)
          end
        end
        
        context 'when the embed is approving and there are' do
          context 'approving filters defined' do
            it 'responds with all items that were marked as approved'
          end
          context 'blocking filters defined' do
            it 'doesn\'t respond with items that were marked as blocked'
          end
        end
      end
    end
  end
end
