require 'domain/spec_helper'

Dir[File.join('app', 'domain', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end
