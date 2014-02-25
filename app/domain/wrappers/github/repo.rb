module Wrappers
  module Github

    class Repo
      extend DataAccessible
      include CoreHelpers

      has :name, :url

      def initialize(repo)
        @data = symbolize_keys(repo)
      end
    end

  end
end
