module Entities
  module Twitter
    class Tweet < Protocol; end
    class Follow < Protocol; end
  end
end

require_relative 'types/tweet'
require_relative 'types/follow'
