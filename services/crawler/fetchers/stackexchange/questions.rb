module Fetchers
  module Stackexchange

    class Questions < Base

      def url
        "https://api.stackexchange.com/2.2/questions"
      end
    end
  end
end

