require 'rails_helper'

describe Organizations::OrganizationBuilder do
  describe '#build' do 
    context 'given an account and a plan' do
      it 'makes associations to the organization' do

        account = FactoryGirl.create(:account)
        plan = FactoryGirl.create(:plan)
        
        org_builder = Organizations::OrganizationBuilder.new(account, plan)
        org_builder.build

        expect(org_builder.organization.accounts).to include(account)
        expect(org_builder.brand).to be_truthy
        expect(org_builder.subscription.plan).to eq plan
        expect{org_builder.save!}.not_to raise_error
      end
    end
  end
end
