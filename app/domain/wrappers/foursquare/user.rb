require 'wrappers/data_accessible'

module Wrappers
  module Foursquare

    class User
      include DataAccessible
      include CoreHelpers

      has :id, :firstName, :lastName
      maybe_has :gender, :homeCity, :contact

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
