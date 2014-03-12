# require rake manually, otherwise migrations will fail :/
require 'rake'
require './lib/apartment_ext'

# require 'apartment/elevators/generic'
# require 'apartment/elevators/domain'
require 'apartment/elevators/subdomain'

#
# Apartment Configuration
#
Apartment.configure do |config|
  config.excluded_models = %w{Tenant}
  config.use_schemas = true
  config.use_structure_sql = true
  config.tenant_names = lambda{ Tenant.pluck :login }

  # config.default_schema = "public"
  # config.persistent_schemas = %w{ hstore }
end

# Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
#   # TODO: supply generic implementation
# }
# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain'
