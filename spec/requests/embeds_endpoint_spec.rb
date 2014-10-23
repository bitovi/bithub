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

  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
    @current_brand = Brand.where(name: 'neektza').first
  end

  describe 'GET /embeds' do
    it 'responds with all embeds (for current brand)' do
      Apartment::Database.switch('neektza')
      embeds = FactoryGirl.create_list(:embed, 10, brand: @current_brand)

      get "/api/#{api_version}/embeds"
      expect(response).to be_success
      expect(json.length).to eq(embeds.length)
    end
  end

  describe 'GET /embeds/:id' do
    it 'responds with an embed' do
      Apartment::Database.switch('neektza')
      FactoryGirl.create(:embed, brand: @current_brand)

      get "/api/#{api_version}/embeds/1"
      expect(response).to be_success
      expect(json).to have_keys(%w(name colorscheme layout))
    end
  end

  describe 'POST /embeds' do
    it 'creates a new embed for the current brand' do
      post "/api/#{api_version}/embeds", { embed: embed_creation_data }
      expect(response).to be_success
      expect(json).to have_keys(%w(name colorscheme layout))
    end
  end
end
