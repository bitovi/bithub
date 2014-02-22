module Wrappers
  module Github

    class Labels
      include CoreHelpers

      def initialize(labels)
        @ls = symbolize_keys(labels)
      end

      def label_names
        @ls.map {|l| l[:name]}
      end

      def label_names_csv
        label_names.join(',')
      end
    end

  end
end
