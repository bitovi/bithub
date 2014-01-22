module Events
  module Github

    class Download
      include Constructable
      include Persistable
      include Events::Github::Accessors::Standard

      def name
        payload.andand[:download].andand[:name]
      end

      def description
        payload.andand[:download].andand[:description]
      end

      def url
        payload.andand[:download].andand[:html_url]
      end
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "download #{original_hash['payload']['download']['name']} created",
#     :body => original_hash['payload']['download']['description'],
#     :url => original_hash['payload']['download']['html_url'],
#   }
# })
