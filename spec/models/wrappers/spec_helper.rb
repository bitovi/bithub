require 'models/spec_helper'

Dir[File.join('app', 'models', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/models/', '')
end
