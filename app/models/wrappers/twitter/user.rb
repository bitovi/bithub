require 'wrappers/data_accessible'

module Wrappers
  module Twitter

    class User
      include DataAccessible
      include CoreHelpers

      has :id, :profile_image_url

      def initialize(user)
        @data = symbolize_keys(user)
      end

      def screen_name
        @data[:screen_name] || ""
      end

      alias_method :name, :screen_name
    end
  end
end
