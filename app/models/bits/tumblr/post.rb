require 'bits/protocol'
require_relative 'shared'

module Bits
  module Tumblr

    class Post < Protocol
      include Shared

      def find
        @event.id && find_by_tumblr_id.first
      end

      def find_by_tumblr_id
        Bit
          .feed('tumblr')
          .where(origin_id: @event.id)
      end
    end
  end
end
