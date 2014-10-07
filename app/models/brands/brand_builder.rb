module Brands
  class BrandBuilder

    def initialize(account)
      @account = account
    end

    def build
      @brand = Brand.new({name: brand_name, tenant_name: brand_name})
      @brand.accounts << account
      self
    end

    def save
      @brand.create_tenant if @brand.save
    end
    
    def brand_name
      @account.email.split('@').first.gsub(/[^\w-]/,'-')
    end

  end
end
