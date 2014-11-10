module Brands
  class BrandBuilder

    attr_reader :account, :brand, :plan

    def initialize(account, plan)
      @account = account

      # validate if plan exists!
      @plan = plan
    end

    def build
      @brand = Brand.new({name: brand_name, tenant_name: brand_name})
      @brand.accounts << @account
      self
    end

    def save
      # subscription creates Stripe's customer,
      # so call it after the brand itself is successfully cerated
      create_subscription if @brand.save
    end

    def brand_name
      @account.email.split('@').first.gsub(/[^\w-]/,'-')
    end

    private

    def create_subscription
      @brand.subscription = Subscription.new(plan_id: @plan)
      @brand.save
    end

  end
end
