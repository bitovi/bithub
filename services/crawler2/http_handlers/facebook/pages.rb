module HttpHandlers
  module Facebook
    class Pages
      include Protocol

      def handle
        respond body: "Handling Facebook Page"
      end

    end
  end
end
