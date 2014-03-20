require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class User
      include DataAccessible
      include CoreHelpers

      has :id, :screen_name, :profile_image_url
      alias_method :name, :screen_name

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
