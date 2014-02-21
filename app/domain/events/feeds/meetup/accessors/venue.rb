module Events
  module Meetup
    module Accessors

      class Venue
        include CoreHelpers

        def initialize(venue)
          @v = symbolize_keys(venue)
        end

        def name
          @v[:name]
        end

        def country
          ((country = (@v[:country] || '')) == 'us') ? country.upcase : country.capitalize
        end

        def address
          [@v[:address_1], @v[:address_2], @v[:address_3]].compact.join(' ')
        end

        def city
          [@v[:city], @v[:state], @v[:zip]].compact.join(' ')
        end

        def lat
          (@v[:lat] || "").to_s
        end

        def lon
          (@v[:lon] || "").to_s
        end
      end

    end
  end
end
