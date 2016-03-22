require 'core_ext'

module Organizations
  class OrganizationBuilder
    class BuildingError < StandardError; end;

    attr_reader :account, :organization, :plan, :brand, :subscription

    def initialize(account, params)
      @account = account
	  @params = params
    end

    def build
      fail BuildingError.new if !@account.valid?
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

      @subscription = @organization.build_subscription(plan: nil)

      self
    end

    def save!
      @organization.save!

      @subscription.create_stripe_customer! if ENV['STRIPE_ENABLE'].to_bool
      delete_excluded_tables_from_tenant brand_name

      @account.add_role(:organization_admin, @organization)
      @account.save!
      
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
