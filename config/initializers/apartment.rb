# require rake manually, otherwise migrations will fail :/
require 'rake'

# Require whichever elevator you're using below here...
#
# require 'apartment/elevators/generic'
# require 'apartment/elevators/domain'
require 'apartment/elevators/subdomain'


#
# Apartment Configuration
#
Apartment.configure do |config|

  # These models will not be multi-tenanted,
  # but remain in the global (public) namespace

  config.excluded_models = %w{Tenant}
  config.use_schemas = true

  #config.persistent_schemas = %w{public}

  # add the Rails environment to database names?
  # config.prepend_environment = true
  # config.append_environment = true

  # supply list of database names for migrations to run on
  config.tenant_names = lambda{ Tenant.pluck :login }
end

##
# Elevator Configuration

# Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
#   # TODO: supply generic implementation
# }

# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain'

# Rake enhancements so that db:migrate etc... also runs migrations on all tenants
#require 'apartment/tasks/enhancements'
