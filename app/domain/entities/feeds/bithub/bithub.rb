module Entities
  module Bithub
    class Post < Protocol; end

    def self.type(event)
      type_name = event.type_name
      if self.constants.include?(type_name)
        self.const_get(type_name)
      else
        fail MappingError.new("Couldn't find valid type for Bithub", type_name)
      end
    end

  end
end

require_relative 'types/event'
require_relative 'types/post'
