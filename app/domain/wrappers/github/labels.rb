module Wrappers
  module Github

    class Labels
      include CoreHelpers

      def initialize(labels)
        @ls = symbolize_keys(labels)
      end

      def names
        @ls.map {|l| l.fetch(:name)}
      end

      def names_csv
        names.join(',')
      end
    end

  end
end
