require 'rails_helper'

describe Brand do
  describe '.flag_inactive' do

    before(:all) do
      self.use_transactional_fixtures = false
    end

    after(:all) do
      clean_slate
      self.use_transactional_fixtures = true
    end

    it 'marks all Brands as active if by default' do
      clean_slate

      brand = FactoryGirl.create(:brand, name: 'bitovi', tenant_name: 'bitovi', is_active: false)

      Brand.flag_inactive
      expect(brand.reload.is_active).to be_truthy
    end

    it 'marks Brands with unconfirmed accounts under them (that also haven\'t logged in for a week) as inactive' do
      clean_slate

      organization = FactoryGirl.create(:organization)
      brand = FactoryGirl.create(:brand, organization: organization)
      organization.accounts << (account = FactoryGirl.create(:account, last_sign_in_at: 3.weeks.ago, confirmed_at: nil))
      organization.save!

      Brand.flag_inactive
      expect(brand.reload.is_active).to be_falsey
    end
  end

  def clean_slate
    ActiveRecord::Base.connection.execute('DELETE FROM brands; DELETE FROM accounts;')
    Apartment::Tenant.drop('bitovi') if Apartment.connection.schema_exists? 'bitovi'
  end

end
