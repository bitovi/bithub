require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    register_and_login
  end

  context 'given a certain hub id' do
    context 'assuming the request requires admin privileges' do
      context 'and the user is managing the state of individual bits' do

        before do
          @hub = FactoryGirl.create(:hub, brand: Brand.current)
          @bit = FactoryGirl.create(:twitter_tweet)
          @hub.make_link_to(@bit)
        end
        
    # [TODO] FIX TEST
        # describe 'PUT /hub/1/bits/2/approve' do
        #   context 'given a certain bit from an hub' do
        #     it 'approves it' do

        #       put "/api/#{api_version}/hubs/#{@hub.id}/bits/#{@bit.id}/approve"
        #       expect(response).to be_success
        #       expect(json['is_approved']).to be_truthy
        #     end
        #   end
        # end

    # [TODO] FIX TEST
        # describe 'PUT /hub/1/bits/2/disapprove' do
        #   context 'given a certain bit from an hub' do
        #     it 'disaproves it' do
        #       put "/api/#{api_version}/hubs/#{@hub.id}/bits/#{@bit.id}/disapprove"
        #       expect(response).to be_success
        #       expect(json['is_approved']).to be_falsey
        #     end
        #   end
        # end

    # [TODO] FIX TEST
        # describe 'PUT /hub/1/bits/2/pin' do
        #   context 'given a certain bit from an hub' do
        #     it 'pins it to the top' do
        #       put "/api/#{api_version}/hubs/#{@hub.id}/bits/#{@bit.id}/pin"
        #       expect(response).to be_success
        #       expect(json['is_pinned']).to be_truthy
        #     end
        #   end
        # end

    # [TODO] FIX TEST
        # describe 'PUT /hub/1/bits/2/unpin' do
        #   context 'given a certain bit from an hub' do
        #     it 'unpins it from the top' do
        #       put "/api/#{api_version}/hubs/#{@hub.id}/bits/#{@bit.id}/unpin"
        #       expect(response).to be_success
        #       expect(json['is_pinned']).to be_falsey
        #     end
        #   end
        # end
      end
    end

    context 'assuming the request is public' do
      describe 'GET /hub/1/bits' do
        context 'when the hub is blocking and there are no filters' do
          # [TODO] FIX TEST
          # it 'respondwith an empty array' do
          #   hub = FactoryGirl.create(:hub, brand: Brand.current, approved_by_default: false)
          #   hub.make_link_to(FactoryGirl.create(:github_watch))
          #   hub.make_link_to(FactoryGirl.create(:twitter_tweet))

          #   get "/api/#{api_version}/hubs/#{hub.id}/bits?tenant_name=#{Brand.current.name}"
          #   expect(response).to be_success
          #   expect(json['data'].length).to eq(0)
          # end
        end

        context 'when the hub is approving and there are no filters' do
          # [TODO] FIX TEST
          # it 'respond with an empty array' do
          #   hub = FactoryGirl.create(:hub, brand: Brand.current, approved_by_default: true)
          #   hub.make_link_to(FactoryGirl.create(:github_watch))
          #   hub.make_link_to(FactoryGirl.create(:github_issue))

          #   get "/api/#{api_version}/hubs/#{hub.id}/bits?tenant_name=#{Brand.current.name}"
          #   expect(response).to be_success
          #   expect(json['data'].length).to eq(2)
          # end
        end

        context 'when the hub is approving and there are' do
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
