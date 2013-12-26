Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end

module Entities
  module Github
  end
end
