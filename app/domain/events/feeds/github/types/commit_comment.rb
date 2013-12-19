module Events
  module Github
    module CommitComment
      #Relationships = [Entities::Github::CommitComment, Entities::Github::Push]

      class Processor
        def process(origin_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "commented on a commit in #{original_hash['repo']['name']}",
              :body => original_hash['payload']['comment']['body'],
              :url => original_hash['payload']['comment']['html_url'],
            },
            :meta => {
              :commit_id => original_hash['payload']['comment']['commit_id']
            }
          })
        end
      end

    end
  end
end
