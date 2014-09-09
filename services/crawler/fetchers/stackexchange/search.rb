module Fetchers
  module Stackexchange

    class Search < Base

      def url
        "https://api.stackexchange.com/2.2/search"
      end
    end
  end
end
