require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Entities endpoints', type: :request do
  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
    @current_brand = Brand.where(name: 'neektza').first
  end

  context 'given an embed id' do
    describe 'GET /embed/:id/entities/approved' do
      it 'responds with all approved entities assigned to that embed' do
        Apartment::Database.switch('neektza')
        embed = FactoryGirl.create(:embed, brand: @current_brand)
        FactoryGirl.create(:filter, embed: embed)
        FactoryGirl.create(:github_pull_request, embed: embed)
        FactoryGirl.create(:github_push, embed: embed)
        FactoryGirl.create(:github_watch, embed: embed)
        FactoryGirl.create(:entity, embed: embed)




        get '/api/v3/embeds/1/entities'
        expect(response).to be_success
        expect(json.length).to eq(99)
      end
    end
    
    describe 'GET /embed/:id/entities/waitlisted' do
      it 'responds with all entities waiting for approval assigned to that embed' do
        # TODO test

        get '/api/v3/embeds/1/entities/waitlisted'
        expect(response).to be_success
        expect(json.length).to eq(33)
      end
    end
  end
end
