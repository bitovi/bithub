# require rake manually, otherwise migrations will fail :/
require 'rake'

# require 'apartment/elevators/generic'
# require 'apartment/elevators/domain'
require 'apartment/elevators/subdomain'

#
# Apartment Configuration
#
Apartment.configure do |config|
  config.excluded_models = %w{ Brand BrandIdentity Account AccountRole AccountsAccountRole FeedConfig User Identity }
  config.use_schemas = true
  config.use_sql = true
  config.tenant_names = lambda{ Brand.pluck :name }

  # functions created by extensions are in public schema so keep it in search path
  config.persistent_schemas = %w{ public }
end

# Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
#   # TODO: supply generic implementation
# }
# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain'
