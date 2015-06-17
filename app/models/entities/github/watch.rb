require 'entities/protocol'
require_relative 'shared'

module Entities
  module Github

    class Watch < Protocol
      include Shared

      def find
        nil
      end

      def data
        with_commons({
          title: "started watching #{@event.repo.name}"
        })
      end
    end

  end
end
