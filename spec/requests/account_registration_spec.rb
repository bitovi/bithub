require_relative 'request_helpers'

RSpec.describe 'Account registration', type: :request do

  before do
    @brand_plan = FactoryGirl.create(:plan, :brand)
  end

  describe 'POST /register' do
    it 'creates an account, a new brand and subscription for that account' do
      expect do
        post '/accounts', {
          account: AuthTestData::ACCOUNT_REGISTRATION_DATA
        }
      end.to \
        change(Account, :count).by(1)
        change(Brand, :count).by(1).and \
        change(Subscription, :count).by(1)
        change(Organization, :count).by(1)

      expect(Account.first.confirmed?).to be_falsey
    end
  end
end
