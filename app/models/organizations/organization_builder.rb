require 'core_ext'

module Organizations
  class OrganizationBuilder

    attr_reader :account, :organization, :plan, :brand, :subscription

    def initialize(account, plan=nil)
      @account = account
      @plan    = plan
    end

    def build
      @organization  = Organization.new name: organization_name
      @brand         = Brand.new name: brand_name, tenant_name: brand_name
      @subscription  = Subscription.new plan: @plan

      @account.organizations << @organization
      @organization.accounts << @account
      @organization.brands   << @brand
      @organization.subscription = @subscription
      self
    end

    def save!
      @organization.save!
      @subscription.create_stripe_customer! if ENV['STRIPE_ENABLE'].to_bool
      self
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
