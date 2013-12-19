module Events
  module Github
    module CustomIssue
      #Relationships = [Entities::Github::Issue]

      RELEVANT_CONTENT_ATTRS = ['id', 'title', 'body', 'labels', 'state']

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            #content_digest: content_digest(original_hash),
            #label_names: label_names(labels(original_hash)),
            meta: {
              type: 'custom_issue_event',
            }
          })
        end

        def labels(original_hash)
          original_hash['labels']
        end

        def label_names(labels)
          labels.map {|l| l['name'] }.join(',') if labels
        end

        def content_digest(original_hash)
          seed = RELEVANT_CONTENT_ATTRS.reduce("") {|memo, attr| memo += original_hash[attr].to_s}
          Digest::MD5.hexdigest(seed)
        end
      end

    end
  end
end
