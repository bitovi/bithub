require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Hub endpoints', type: :request do
  let(:api_version) { 'v3' }

  let(:hub_creation_data) {
    { name: 'some name', approved_by_default: true }
  }

  before do
    register_and_login
  end

  context 'given the user is logged in and the brand is determined' do
    # [TODO] FIX TEST
    # describe 'GET /hubs' do
    #   it 'responds with all hubs' do
    #     hubs = []
    #     hubs << FactoryGirl.create(:hub, name: "First hub", brand: Brand.current)

    #     get "/api/#{api_version}/hubs"
    #     expect(response).to be_success
    #     expect(json.length).to eq(hubs.length)
    #   end
    # end

    # [TODO] FIX TEST
    # describe 'GET /hubs/:id' do
    #   it 'responds with a specific hub' do
    #     FactoryGirl.create(:hub, brand: Brand.current)

    #     get "/api/#{api_version}/hubs/1"
    #     expect(response).to be_success
    #     expect(json.keys).to include('name', 'approved_by_default')
    #   end
    # end
    
    # [TODO] FIX TEST
    # describe 'PUT /hubs/:id' do
    #   it 'updates an existing hub' do
    #     e = FactoryGirl.create(:hub, name: 'original name', brand: Brand.current)

    #     put "/api/#{api_version}/hubs/#{e.id}", { hub: { name: 'updated name' } }
    #     expect(response).to be_success
    #     expect(json['name']).to eq 'updated name'
    #   end
    # end

    # [TODO] FIX TEST
    # describe 'POST /hubs' do
    #   it 'creates a new hub' do
    #     post "/api/#{api_version}/hubs", { hub: hub_creation_data }
    #     expect(response).to be_success
    #     expect(json.keys).to include('name', 'approved_by_default')
    #   end
    # end

    # [TODO] FIX TEST
    # describe 'POST /hubs/1/embeds' do
    #   it 'creates a new hub' do
    #     post "/api/#{api_version}/hubs", { hub: hub_creation_data }
    #     expect(response).to be_success
    #     expect(json.keys).to include('name', 'approved_by_default')
    #   end
    # end

    describe 'DELETE /hubs/:id' do
      it 'destroys an existing hub' do
        hub = FactoryGirl.create(:hub, brand: Brand.current)
        delete "/api/v3/hubs/#{hub.id}"
        expect(Service.count).to eq 0
      end
    end
  end
end
