module Events
  module Github

    class GistEvent
      include Constructable
      include Events::Github::Accessors::Standard

      def action
        payload.andand[:action]
      end

      def html_url
        payload.andand[:gist].andand[:html_url]
      end

      def description
        payload.andand[:gist].andand[:description]
      end
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "Gist #{original_hash['payload']['action']}: #{original_hash['payload']['gist']['description']}",
#     :url => original_hash['payload']['gist']['url'],
#   },
#   meta: {
#     :action => original_hash['payload']['action']
#   }
# })
