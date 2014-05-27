require 'wrappers/data_accessible'

module Wrappers
  module Foursquare

    class Venue
      include DataAccessible
      include CoreHelpers

      has :id, :name, :contact, :location, :categories, :stats
      maybe_has :url, :hours, :rating, :tips, :likes

      def initialize(venue)
        @data = symbolize_keys(venue)
      end

    end
  end
end
