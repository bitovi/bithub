require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Embed endpoints', type: :request do
  let(:embed_creation_data) {
    {
      name: 'some name',
      colorscheme: '#FFF,#000',
      layout: 'left-right',
      approved_by_default: true
    }
  }

  let(:api_version) { 'v3' }

  before do
    StripeMock.start
    StripeMock.create_test_helper.create_plan(id: 'starter', amount: 1000, trial_period_days: 45)
  end
  after do
    StripeMock.stop
  end

  before(:each) do
    post '/register/starter', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Account.find_by_email(AuthTestData::ACCOUNT_REGISTRATION_DATA[:email]).brands.first
  end

  context 'given the account is logged in and the brand is determined' do
    describe 'GET /embeds' do
      it 'responds with all embeds' do
        embeds = []
        embeds << FactoryGirl.create(:embed, name: "First embed", brand: @current_brand)
        embeds << FactoryGirl.create(:embed, name: "Second embed", brand: @current_brand)
        embeds << FactoryGirl.create(:embed, name: "Third embed", brand: @current_brand)

        get "/api/#{api_version}/embeds"
        expect(response).to be_success
        expect(json.length).to eq(embeds.length)
      end
    end

    describe 'GET /embeds/:id' do
      it 'responds with a specific embed' do
        FactoryGirl.create(:embed, brand: @current_brand)

        get "/api/#{api_version}/embeds/1"
        expect(response).to be_success
        expect(json.keys).to include('name', 'colorscheme', 'layout', 'approved_by_default')
      end
    end

    describe 'PUT /embeds/:id' do
      it 'updates an existing embed' do
        e = FactoryGirl.create(:embed, name: 'original name', brand: @current_brand)

        put "/api/#{api_version}/embeds/#{e.id}", { embed: { name: 'updated name' } }
        expect(response).to be_success
        expect(json['name']).to eq 'updated name'
      end
    end

    describe 'POST /embeds' do
      it 'creates a new embed' do
        post "/api/#{api_version}/embeds", { embed: embed_creation_data }
        expect(response).to be_success
        expect(json.keys).to include('name', 'colorscheme', 'layout', 'approved_by_default')
      end
    end

    describe 'POST /embeds/1/presets' do
      it 'creates a new embed' do
        post "/api/#{api_version}/embeds", { embed: embed_creation_data }
        expect(response).to be_success
        expect(json.keys).to include('name', 'colorscheme', 'layout', 'approved_by_default')
      end
    end

    describe 'DELETE /embeds/:id' do
      it 'destroys an existing embed' do
        embed = FactoryGirl.create(:embed, brand: @current_brand)
        delete "/api/v3/embeds/#{embed.id}"
        expect(Service.count).to eq 0
      end
    end
  end
end
