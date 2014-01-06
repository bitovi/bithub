module Events
  module Github
    module CommitComment

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "commented on a commit in #{original_hash['repo']['name']}",
              :body => original_hash['payload']['comment']['body'],
              :url => original_hash['payload']['comment']['html_url'],
            },
            :meta => {
              :commit_id => original_hash['payload']['comment']['commit_id'],
            }
          })
        end

      end

    end
  end
end
