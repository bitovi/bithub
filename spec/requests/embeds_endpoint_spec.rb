require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Embed endpoints', type: :request do
  let(:embed_creation_data) {
    {
      name: 'some name',
      colorscheme: '#FFF,#000',
      layout: 'left-right'
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
        Apartment::Tenant.switch @current_brand.tenant_name do
          embeds = FactoryGirl.create_list(:embed, 10, brand: @current_brand)

          get "/api/#{api_version}/embeds"
          expect(response).to be_success
          expect(json.length).to eq(embeds.length)
        end
      end
    end

    describe 'GET /embeds/:id' do
      it 'responds with a specific embed' do
        Apartment::Tenant.switch @current_brand.tenant_name do
          FactoryGirl.create(:embed, brand: @current_brand)

          get "/api/#{api_version}/embeds/1"
          expect(response).to be_success
          expect(json.keys).to include('name', 'colorscheme', 'layout')
        end
      end
    end

    describe 'POST /embeds' do
      it 'creates a new embed' do
        post "/api/#{api_version}/embeds", { embed: embed_creation_data }
        expect(response).to be_success
        expect(json.keys).to include('name', 'colorscheme', 'layout')
      end
    end

    describe 'PUT /embeds' do
      it 'updates an existing embed' do
        Apartment::Tenant.switch @current_brand.tenant_name do
          e = FactoryGirl.create(:embed, brand: @current_brand)

          put "/api/#{api_version}/embeds/#{e.id}", { embed: { name: 'myname' } }
          expect(response).to be_success
          expect(json['name']).to eq 'myname'
        end
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
