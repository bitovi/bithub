module Events
  module Github
    module Push
      #Relationships = [Entities::Github::Issue, Entities::Github::PullRequest]

      class Processor
        def process(original_hash, processed)
          new_data = {
            extracted: {
              :title => "pushed to #{original_hash['repo']['name']}",
              :body => original_hash['payload']['body'],
              :url => "http://github.com/#{original_hash['repo']['name']}/commit/#{original_hash['payload']['head']}",
            },
            meta: {
              :commit_shas => original_hash['payload']['commits'].map{|c| c['sha']}.join(','),
              :repo_name => original_hash['repo']['name'],
              :push_id => original_hash['payload']['push_id'],
            }
          }

          processed.deep_merge(new_data)
        end
      end

    end
  end
end
