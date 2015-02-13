require 'wrappers/data_accessible'

module Wrappers
  module Facebook

    class To
      include DataAccessible
      include CoreHelpers

      has :id, :name, :category

      def initialize(data)
        @data = symbolize_keys(data)
      end

    end
  end
end
