require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    register_and_login
  end

  context 'given the user is logged in and the brand is determined' do
    context 'and given a certain hub id' do
      # [TODO] FIX TEST
      # describe 'GET /embeds' do
      #   it 'gets all bits belonging to an hub' do
      #     hub = FactoryGirl.create(:hub, brand: Brand.current)
      #     FactoryGirl.create(:hub_preset, name: 'preset1', hub: hub)
      #     FactoryGirl.create(:hub_preset, name: 'preset2', hub: hub)

      #     get "/api/#{api_version}/embeds?hub_id=#{hub.id}"
      #     expect(response).to be_success
      #     expect(json['data'].length).to eq(2)
      #   end
      # end
      
      # [TODO] FIX TEST
      # describe 'GET /embeds/1' do
      #   it 'gets a specific preset' do
      #     hub = FactoryGirl.create(:hub, brand: Brand.current)
      #     FactoryGirl.create(:hub_preset, name: 'preset1', hub: hub)

      #     get "/api/#{api_version}/embeds/1?hub_id=#{hub.id}"
      #     expect(response).to be_success
      #     expect(json.keys).to include('name', 'config')
      #   end
      # end

    # [TODO] FIX TEST
      # describe 'POST /embeds' do
      #   it 'gets all bits belonging to an hub' do
      #     hub = FactoryGirl.create(:hub, brand: Brand.current)

      #     post "/api/#{api_version}/embeds", {
      #       preset: {
      #         name: 'a nice preset',
      #         config: {
      #           first_key: 'first_val',
      #           snd_key: 'snd_val'
      #         }
      #       }
      #     }.to_json, AuthTestData::POST_HEADERS

      #     expect(response).to be_success
      #     expect(json.keys).to include('name', 'config')
      #   end
      # end

    # [TODO] FIX TEST
      # describe 'PUT /embeds/1' do
      #   it 'update a specific preset' do
      #     hub = FactoryGirl.create(:hub, brand: Brand.current)
      #     FactoryGirl.create(:hub_preset, name: 'original name', hub: hub)

      #     put "/api/#{api_version}/embeds/1?hub_id=#{hub.id}", {
      #       preset: { name: 'updated name' }
      #     }

      #     expect(response).to be_success
      #     expect(json['name']).to eq 'updated name'
      #   end
      # end

    # [TODO] FIX TEST
      # describe 'DELETE /embeds/1' do
      #   it 'deletes a specific preset' do
      #     hub = FactoryGirl.create(:hub, brand: Brand.current)
      #     preset = FactoryGirl.create(:hub_preset, name: 'a preset', hub: hub)

      #     delete "/api/v3/embeds/#{preset.id}"
      #     expect(HubEmbed.count).to eq 0
      #   end
      # end

    end
  end
end
