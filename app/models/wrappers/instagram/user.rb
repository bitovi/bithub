require 'wrappers/data_accessible'

module Wrappers
  module Instagram

    class User
      include DataAccessible
      include CoreHelpers

      has :id, :username, :full_name, :website, :bio, :profile_picture

      def initialize(user)
        @data = symbolize_keys(user)
      end

    end
  end
end
