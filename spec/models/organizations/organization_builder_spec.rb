require 'rails_helper'

describe Organizations::OrganizationBuilder do
  describe '#build' do
    context 'given an user and a plan' do
      it 'makes associations to the organization' do

        user = FactoryGirl.create(:user)
        plan = FactoryGirl.create(:plan)

        org_builder = Organizations::OrganizationBuilder.new(user, {})
        org_builder.build.save!

        expect(org_builder.organization.users).to include(user)
        expect(org_builder.user.organizations).to include(org_builder.organization)
        expect(org_builder.brand).to be_truthy
        expect{org_builder.save!}.not_to raise_error
      end
    end
  end
end
