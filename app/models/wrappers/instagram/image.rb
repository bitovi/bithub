require 'wrappers/data_accessible'

module Wrappers
  module Instagram

    class Image
      include DataAccessible
      include CoreHelpers

      has :url, :width, :height

      def initialize(image)
        @data = symbolize_keys(image)
      end

    end
  end
end
