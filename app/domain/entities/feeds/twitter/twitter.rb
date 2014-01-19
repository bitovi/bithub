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
    
    class Tweet; end
    class Follow; end
  end
end

require 'entities/feeds/twitter/types/tweet'
require 'entities/feeds/twitter/types/follow'
