module Wrappers
  module Github

    class Repo
      include CoreHelpers

      def initialize(repo)
        @r = symbolize_keys(repo)
      end

      def to_hash
        @r
      end

      def name
        @r.andand[:name]
      end

    end

  end
end
