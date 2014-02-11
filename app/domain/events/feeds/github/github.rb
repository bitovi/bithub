require_relative 'accessors'

# Require all github types
Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end
