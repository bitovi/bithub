module Wrappers
  module Github

    class User
      extend DataAccessible
      include CoreHelpers

      data_accessors :id, :login, :gravatar_id, :avatar_url

      def initialize(actor)
        @data = symbolize_keys(actor)
      end
    end

  end
end
