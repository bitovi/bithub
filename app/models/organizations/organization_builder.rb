module Organizations
  class OrganizationBuilder

    attr_reader :account, :organization, :plan, :brand, :subscription

    def initialize(account, plan)
      @account = account
      @plan    = plan
    end

    def build
      @organization = Organization.new name: organization_name

      @organization_account = @organization.account_organizations.build(
        account: @account,
        invitation_created_at: DateTime.now,
        invitation_accepted_at: DateTime.now
      )

      @brand = @organization.brands.build(
        name: brand_name,
        tenant_name: brand_name
      )

      @subscription = @organization.build_subscription(plan: @plan)
      

      self
    end

    def save!
      @organization.save!

      @account.add_role(:admin, @organization)
      @account.save!

      @subscription.create_stripe_customer! if ENV['STRIPE_ENABLE'].to_bool && @plan.stripe_id
    end

    def organization_name
      @organization_name ||= pretty_name
    end

    def brand_name
      @brand_name ||= pretty_name
    end

    private

    def pretty_name
      Bazaar.heroku.gsub('-','_')
    end

  end
end
