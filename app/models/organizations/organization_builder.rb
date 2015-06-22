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
      @organization.brands   << @brand
      @organization.subscription = @subscription
      self
    end

    def save!
      @organization.save!
      @subscription.create_stripe_customer! if ENV['STRIPE_ENABLE'].to_bool
      delete_excluded_tables_from_tenant brand_name

      self
    end

    def organization_name
      @organization_name ||= pretty_name
    end

    def brand_name
      @brand_name ||= pretty_name
    end

    private

    def delete_excluded_tables_from_tenant(schema)
      Apartment.excluded_models.each do |m|
        table_name = Object.const_get(m).table_name.split('.').last # removes 'public.*'
        ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS \"#{schema}\".\"#{table_name}\";"
      end
    end

    def pretty_name
      Bazaar.heroku.gsub('-','_')
    end

  end
end
