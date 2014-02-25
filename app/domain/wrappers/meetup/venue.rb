module Wrappers
  module Meetup

    class Venue
      extend DataAccessible
      include CoreHelpers

      has :name, :lat, :lon

      def initialize(venue)
        @data = symbolize_keys(venue)
      end

      def country
        ((country = (@data[:country] || '')) == 'us') ? country.upcase : country.capitalize
      end

      def address
        [@data[:address_1], @data[:address_2], @data[:address_3]].compact.join(' ')
      end

      def city
        [@data[:city], @data[:state], @data[:zip]].compact.join(' ')
      end
        
      def composite_location
        "#{name}, #{address}, #{city}, #{country}"
      end

    end

  end
end
