require 'wrappers/data_accessible'

module Wrappers
  module Meetup

    class Group
      include CoreHelpers
      include DataAccessible

      has :name, :urlname

      def initialize(group)
        @data = symbolize_keys(group)
      end
    end
  end
end
