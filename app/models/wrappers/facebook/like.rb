require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Like
      include DataAccessible
      include CoreHelpers

      has :id, :name

      def initialize(data)
        @data = symbolize_keys(data)
      end

    end
  end
end
