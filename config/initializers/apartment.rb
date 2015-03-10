# require rake manually, otherwise migrations will fail :/
require 'rake'

require 'apartment/elevators/generic'

DEFAULT_BITHUB_TENANT = 'public'

Apartment.configure do |config|
  config.excluded_models = %w(InviteCode Brand BrandIdentity Account AccountsBrand AccountRole AccountsAccountRole User BrandsUser Country Subscription Payment StripeWebhooksLog Plan)
  config.use_schemas = true
  config.use_sql = true
  config.tenant_names = -> { Brand.pluck :tenant_name }
  config.persistent_schemas = [ DEFAULT_BITHUB_TENANT ]
  config.default_schema = DEFAULT_BITHUB_TENANT
end

Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
  tenant_name = request.session['tenant_name']

  Apartment.tenant_names.include?(tenant_name) ? tenant_name : DEFAULT_BITHUB_TENANT
}
