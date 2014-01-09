module Events
  module Github

    class CustomIssue
      include Constructable
      DIGEST_ATTRS = [:issue_id, :title, :body, :labels, :state, :updated_at]
      
      def content_digest
        seed = DIGEST_ATTRS.reduce("") {|accumul, attr| accumul += self.send(attr).to_s}
        Digest::MD5.hexdigest(seed)
      end

      def issue_id
        # FIXME ?
      end
      
      def title
        source_data.andand[:title]
      end

      def body
        source_data.andand[:body]
      end

      def html_url
        source_data.andand[:html_url]
      end

      def labels
        source_data.andand[:labels]
      end

      def label_names
        labels.map(&:name)
      end

      def state
        source_data.andand[:state]
      end

      def number
        source_data.andand[:number]
      end
      
      def repo_name
        # FIXME ?
      end
    end

  end
end
