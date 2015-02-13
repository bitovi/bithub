module Entities
  module Facebook
    class Status < Protocol; end
    class Photo < Protocol; end
    # class Comment < Protocol; end
  end
end

require_relative 'types/status'
require_relative 'types/photo'
#require_relative 'types/comment'
