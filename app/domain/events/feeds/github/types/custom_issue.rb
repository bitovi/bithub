module Events
  module Github
    module CustomIssue

      RELEVANT_CONTENT_ATTRS = ['id', 'title', 'body', 'labels', 'state']

      class Extractor


        # def labels(original_hash)
        #   original_hash['labels']
        # end

        # def label_names(labels)
        #   labels.map {|l| l['name'] }.join(',') if labels
        # end

      end

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({

            extracted: {
              title: original_hash['title'],
              body: original_hash['body'],
              url: original_hash['html_url'],
            },
            meta: {
              feed: 'github',
              type: 'custom_issue_event',
              # labels: label_names(labels(original_hash)),
              # :issue_id => original_hash['id'],
              # :state => original_hash['state'],
              # :issue_number => original_hash['number'],
              # :repo_name => original_hash['repo']['name'],
            }
          })
        end


        def content_digest(original_hash)
          seed = RELEVANT_CONTENT_ATTRS.reduce("") {|memo, attr| memo += original_hash[attr].to_s}
          Digest::MD5.hexdigest(seed)
        end
      end

    end
  end
end
