# Require all github shared wrappers accessors for wrapper classes

require_relative 'accessors'
require_relative 'reference'

Dir[File.join('app', 'domain', 'wrappers', 'github', '**', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end

# Require all github types
Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end
