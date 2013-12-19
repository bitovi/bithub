require 'app/domain/events/shared/with_labels'
  
module Events
  module Github
    module Issue
      #Relationships = [Entities::Github::Issue]

      class Processor
        include Events::Github::WithLabels

        def process(original_hash, processed)
          t = original_hash['payload']['issue']['title']
          nmb = original_hash['payload']['issue']['number']
          state = original_hash['payload']['issue']['state']
          action = original_hash['payload']['action']

          if action == 'opened'
            title = t
          else
            title = "Issue #{action}: #{t}"
          end

          new_data = {
            extracted: {
              :title => title,
              :body => original_hash['payload']['issue']['body'],
              :url => original_hash['payload']['issue']['html_url'],
            },
            :meta => {
              :labels => label_names(labels(original_hash)),
              :issue_id => original_hash['payload']['issue']['id'],
              :action => original_hash['payload']['action'],
              :repo_name => original_hash['repo']['name'],
              :state => state,
              :issue_number => nmb
            }
          }

          processed.deep_merge(new_data)
        end
      end

    end
  end
end
