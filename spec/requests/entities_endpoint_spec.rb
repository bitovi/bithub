require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Entities endpoints', type: :request do
  before(:each) do
    post '/register', { account: account_registration_data }
    post '/login', { account: account_login_data }
    @current_brand = Brand.where(name: 'neektza').first
  end

  let(:api_version) { 'v3' }

  context 'given an embed id' do
    describe 'GET /embed/:id/entities/approved' do
      it 'responds with all approved entities assigned to that embed' do
        Apartment::Database.switch('neektza')
        embed = FactoryGirl.create(:embed, brand: @current_brand)
        filter = FactoryGirl.create(:filter, classification: 'moderating')
        filter.natlang_queries << FactoryGirl.create(:natlang_query, :is_from_github)
        filter.natlang_queries << FactoryGirl.create(:natlang_query, :contains_canjs)

        embed.make_link_to(FactoryGirl.create(:github_pull_request))
        embed.make_link_to(FactoryGirl.create(:github_push))
        embed.make_link_to(FactoryGirl.create(:github_watch))
        embed.make_link_to(FactoryGirl.create(:twitter_tweet))
        embed.make_link_to(FactoryGirl.create(:twitter_follow))

        get "/api/#{api_version}/embeds/1/entities"
        expect(response).to be_success
        pending('todo')
      end
    end

    describe 'GET /embed/:id/entities/waitlisted' do
      it 'responds with all entities waiting for approval assigned to that embed'
    end
  end
end
