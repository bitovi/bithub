module Entities
  module Twitter
    class Tweet < Protocol; end
    class Follow < Protocol; end

    MAPPINGS = {
      :CustomFollow => :Follow,
    }

    def self.type(payload)
      type_name = payload.type_name.capitalize.andand.to_sym
      if MAPPINGS.include?(type_name) && self.constants.include?(MAPPINGS[type_name])
        self.const_get(MAPPINGS[type_name])
      elsif self.constants.include?(type_name)
        self.const_get(type_name)
      else
        fail MappingError.new("Couldn't find valid type for Twitter", type_name)
      end
    end

  end
end

require_relative 'types/tweet'
require_relative 'types/follow'
