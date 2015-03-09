module Organizations
  class OrganizationBuilder

    attr_reader :account, :organization, :plan, :brand

    def initialize(account, plan)
      @account = account
      @plan    = plan
    end

    def build
      @organization  = Organization.new name: organization_name
      @brand         = Brand.new name: brand_name, tenant_name: brand_name
      @subscription  = Subscription.new plan: @plan

      @organization.accounts << @account
      @organization.brands   << @brand
      @organization.subscription = @subscription
      self
    end

    def save!
      @organization.save!
    end

    def organization_name
      @brand_name ||= Bazaar.heroku.gsub('-','_')
    end

    def brand_name
      @brand_name ||= Bazaar.heroku.gsub('-','_')
    end
  end
end
