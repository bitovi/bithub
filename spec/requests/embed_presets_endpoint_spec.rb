require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Filter endpoints', type: :request do
  let(:api_version) { 'v3' }

  before do
    register_and_login
  end

  context 'given the account is logged in and the brand is determined' do
    context 'and given a certain embed id' do

      describe 'GET /presets' do
        it 'gets all entities belonging to an embed' do
          embed = FactoryGirl.create(:embed, brand: Brand.current)
          FactoryGirl.create(:embed_preset, name: 'preset1', embed: embed)
          FactoryGirl.create(:embed_preset, name: 'preset2', embed: embed)

          get "/api/#{api_version}/presets?embed_id=#{embed.id}"
          expect(response).to be_success
          expect(json['data'].length).to eq(2)
        end
      end

      describe 'GET /presets/1' do
        it 'gets a specific preset' do
          embed = FactoryGirl.create(:embed, brand: Brand.current)
          FactoryGirl.create(:embed_preset, name: 'preset1', embed: embed)

          get "/api/#{api_version}/presets/1?embed_id=#{embed.id}"
          expect(response).to be_success
          expect(json.keys).to include('name', 'config')
        end
      end

      describe 'POST /presets' do
        it 'gets all entities belonging to an embed' do
          embed = FactoryGirl.create(:embed, brand: Brand.current)

          post "/api/#{api_version}/presets", {
            preset: {
              name: 'a nice preset',
              config: {
                first_key: 'first_val',
                snd_key: 'snd_val'
              }
            }
          }.to_json, AuthTestData::POST_HEADERS

          expect(response).to be_success
          expect(json.keys).to include('name', 'config')
        end
      end

      describe 'PUT /presets/1' do
        it 'update a specific preset' do
          embed = FactoryGirl.create(:embed, brand: Brand.current)
          FactoryGirl.create(:embed_preset, name: 'original name', embed: embed)

          put "/api/#{api_version}/presets/1?embed_id=#{embed.id}", {
            preset: { name: 'updated name' }
          }

          expect(response).to be_success
          expect(json['name']).to eq 'updated name'
        end
      end

      describe 'DELETE /presets/1' do
        it 'deletes a specific preset' do
          embed = FactoryGirl.create(:embed, brand: Brand.current)
          preset = FactoryGirl.create(:embed_preset, name: 'a preset', embed: embed)

          delete "/api/v3/presets/#{preset.id}"
          expect(EmbedPreset.count).to eq 0
        end
      end

    end
  end
end
