require 'app/domain/events/shared/with_labels'

module Events
  module Github
    module IssueComment

      class Processor
        include Events::Github::WithLabels

        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "commented on issue #{original_hash['payload']['issue']['number']}",
              :body => original_hash['payload']['comment']['body'],
              :url => original_hash['payload']['issue']['html_url'],
            },
            meta: {
              :labels => label_names(labels(original_hash)),
              :issue_id => original_hash['payload']['issue']['id'],
              :issue_number => original_hash['payload']['issue']['number'],
              :repo_name => original_hash['repo']['name']
            }
          })
        end
      end

    end
  end
end
