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

      describe 'GET /embed/1/presets' do
        it 'gets all entities belonging to an embed' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          FactoryGirl.create(:embed_preset, name: 'preset1', embed: embed)
          FactoryGirl.create(:embed_preset, name: 'preset2', embed: embed)

          get "/api/#{api_version}/embeds/#{embed.id}/presets"
          expect(response).to be_success
          expect(json['data'].length).to eq(2)
        end
      end
      
      describe 'GET /embed/1/presets/1' do
        it 'gets a specific preset' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)
          FactoryGirl.create(:embed_preset, name: 'preset1', embed: embed)

          get "/api/#{api_version}/embeds/#{embed.id}/presets/1"
          expect(response).to be_success
          expect(json.keys).to include('name', 'config')
        end
      end
      
      describe 'POST /embed/1/presets' do
        it 'gets all entities belonging to an embed' do
          embed = FactoryGirl.create(:embed, brand: @current_brand)

          post "/api/#{api_version}/embeds/#{embed.id}/presets", {
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

    end
  end
end
