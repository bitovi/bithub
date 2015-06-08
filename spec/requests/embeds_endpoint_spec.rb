require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Embed endpoints', type: :request do
  let(:api_version) { 'v3' }

  let(:embed_creation_data) {
    { name: 'some name', approved_by_default: true }
  }

  before do
    register_and_login
  end

  context 'given the account is logged in and the brand is determined' do
    describe 'GET /embeds' do
      it 'responds with all embeds' do
        embeds = []
        embeds << FactoryGirl.create(:embed, name: "First embed", brand: Brand.current)

        get "/api/#{api_version}/embeds"
        expect(response).to be_success
        expect(json.length).to eq(embeds.length)
      end
    end

    describe 'GET /embeds/:id' do
      it 'responds with a specific embed' do
        FactoryGirl.create(:embed, brand: Brand.current)

        get "/api/#{api_version}/embeds/1"
        expect(response).to be_success
        expect(json.keys).to include('name', 'approved_by_default')
      end
    end

    describe 'PUT /embeds/:id' do
      it 'updates an existing embed' do
        e = FactoryGirl.create(:embed, name: 'original name', brand: Brand.current)

        put "/api/#{api_version}/embeds/#{e.id}", { embed: { name: 'updated name' } }
        expect(response).to be_success
        expect(json['name']).to eq 'updated name'
      end
    end

    describe 'POST /embeds' do
      it 'creates a new embed' do
        post "/api/#{api_version}/embeds", { embed: embed_creation_data }
        expect(response).to be_success
        expect(json.keys).to include('name', 'approved_by_default')
      end
    end

    describe 'POST /embeds/1/presets' do
      it 'creates a new embed' do
        post "/api/#{api_version}/embeds", { embed: embed_creation_data }
        expect(response).to be_success
        expect(json.keys).to include('name', 'approved_by_default')
      end
    end

    describe 'DELETE /embeds/:id' do
      it 'destroys an existing embed' do
        embed = FactoryGirl.create(:embed, brand: Brand.current)
        delete "/api/v3/embeds/#{embed.id}"
        expect(Service.count).to eq 0
      end
    end
  end
end
