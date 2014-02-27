module Wrappers
  module Github

    class User
      include DataAccessible
      include CoreHelpers

      has :id, :login, :gravatar_id, :avatar_url

      def initialize(actor)
        @data = symbolize_keys(actor)
      end
    end

  end
end
