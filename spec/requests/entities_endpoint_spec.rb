require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Entities endpoints', type: :request do
  before(:each) do
    post '/register', { account: AuthTestData::ACCOUNT_REGISTRATION_DATA }
    post '/login', { account: AuthTestData::ACCOUNT_LOGIN_DATA }
    @current_brand = Brand.where(name: 'neektza').first
  end

  let(:api_version) { 'v3' }

  context 'given an embed id' do
    describe 'GET /embed/:id/entities/approved' do
      it 'responds with all approved entities assigned to that embed'
    end

    describe 'GET /embed/:id/entities/waitlisted' do
      it 'responds with all entities waiting for approval assigned to that embed'
    end
  end
end
