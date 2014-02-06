module Events
  module Github

    class CustomIssue < Protocol

      DIGEST_ATTRS = [:issue_id, :title, :body, :labels, :state, :updated_at]
      
      def content_digest
        seed = DIGEST_ATTRS.reduce("") {|accumul, attr| accumul += self.send(attr).to_s}
        Digest::MD5.hexdigest(seed)
      end

      def issue_id
        # FIXME ? no attr in source_data
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
        labels.map{|l| l[:name]}
      end

      def state
        source_data.andand[:state]
      end

      def number
        source_data.andand[:number]
      end

      def user
        source_data.andand[:user]
      end

      def origin_author_id
        user.andand[:id]
      end

      def origin_author_name
        user.andand[:login]
      end

      def origin_timestamp
        source_data.andand[:created_at]
      end

      def updated_at
        source_data.andand[:updated_at]
      end
      
      def repo_name
        # FIXME ? how to get ? mayble using REGEX ? :D
      end
        
      def referenced_issue_numbers
        body.scan(/#\d+/).map {|m| m.gsub('#','').to_s}
      end        
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     title: original_hash['title'],
#     body: original_hash['body'],
#     url: original_hash['html_url'],
#   },
#   meta: {
#     feed: 'github',
#     type: 'custom_issue_event',
#     labels: label_names(labels(original_hash)),
#     issue_id: original_hash['id'],
#     state: original_hash['state'],
#     issue_number: original_hash['number'],
#     repo_name: original_hash['repo']['name'],
#   }
# })
