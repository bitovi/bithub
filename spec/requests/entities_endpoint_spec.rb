require 'rails_helper'
require_relative 'request_helpers'

RSpec.describe 'Entities endpoints', type: :request do

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
