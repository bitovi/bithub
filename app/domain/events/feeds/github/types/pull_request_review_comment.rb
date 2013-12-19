module Events
  module Github
    module Follow
      #Relationships = []

      class Processor
        def process(original_hash, processed)
          processed.deep_merge({
            extracted: {
              :title => "commented on pull request: #{original_hash['payload']['comment']['path']}",
              :url => original_hash['payload']['comment']['_links']['html']['href'],
              :body => original_hash['payload']['comment']['body'],
            }
          })
        end
      end

    end
  end
end
