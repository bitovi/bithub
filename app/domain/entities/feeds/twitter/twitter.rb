module Entities
  module Twitter
    MAPPINGS = {
      'CustomFollow' => 'Follow',
    }

    def self.type(payload)
      if MAPPINGS.include?(payload.type)
        self.const_get(MAPPINGS[payload.type])
      else
        self.const_get(payload.type)
      end
    end
    
    class Tweet < Protocol; end
    class Follow < Protocol; end
  end
end

require_relative 'types/tweet'
require_relative 'types/follow'
