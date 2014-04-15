require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class Poster
      include DataAccessible
      include CoreHelpers

      has :id, :name

      def initialize(status)
        @data = symbolize_keys(status)
      end

    end
  end
end
