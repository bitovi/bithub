require 'wrappers/data_accessible'

module Wrappers
  module Foursquare

    class Tip
      include DataAccessible
      include CoreHelpers

      has :id, :text, :createdAt
      maybe_has :user, :vanue

      def initialize(tip)
        @data = symbolize_keys(tip)
      end

    end
  end
end
