module Events
  module Github
    module Push
      #Relationships = [Entities::Github::Issue, Entities::Github::PullRequest]

      class Processor
        def process(original_hash, processed)

          if m = (original_hash['payload']['commits'].map{|c| c['message']}.join(' ')).match(/#(\d*)/)
            issue_nmb = m[1]
          end

          attrs = {
            :title => "pushed to #{original_hash['repo']['name']}",
            :body => original_hash['payload']['body'],
            :url => "http://github.com/#{original_hash['repo']['name']}/commit/#{original_hash['payload']['head']}",
            :meta => {
              :commits => original_hash['payload']['commits'].map{|c| c['sha']}.join(','),
              :commit_shas => original_hash['payload']['commits'].map{|c| c['sha']}.join(','),
              :repo_name => original_hash['repo']['name'],
              :referenced_issue_number => issue_nmb
            }
          }
        end
      end

    end
  end
end
