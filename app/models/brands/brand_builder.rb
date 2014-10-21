module Brands
  class BrandBuilder

    def initialize(account)
      @account = account
    end

    def build
      @brand = Brand.new({name: brand_name, tenant_name: brand_name})
      @brand.accounts << @account
      self
    end

    def save
      @brand.save
    end

    def brand_name
      @account.email.split('@').first.gsub(/[^\w-]/,'-')
    end

  end
end
