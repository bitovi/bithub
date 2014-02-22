module Wrappers
  module Github

    class Repo
      extend DataAccessible
      include CoreHelpers

      data_accessors :name, :url

      def initialize(repo)
        @data = symbolize_keys(repo)
      end
    end

  end
end
