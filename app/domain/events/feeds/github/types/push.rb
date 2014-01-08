module Events
  module Github

    class Push
      include Constructable
      include Events::Github::Accessors::Standard

      def push_id
        payload.andand[:push_id]
      end
      
      def commits
        payload.andand[:commits]
      end

      def commit_shas
        commits.map(&:sha)
      end

      def commit_messages
        commits.map(&:message]
      end

      def commit_shas_csv
        commit_shas.join(',')
      end

      def referenced_repo_name
        repo_name
      end

      def referenced_number
        if md = commit_messages.join(' ').match(/#(\d*)/)
          md.andand[1]
        end
      end
    end

  end
end

# new_data = {
#   extracted: {
#     :title => "pushed to #{original_hash['repo']['name']}",
#     :body => original_hash['payload']['body'],
#     :url => "http://github.com/#{original_hash['repo']['name']}/commit/#{original_hash['payload']['head']}",
#   },
#   meta: {
#     :commit_shas => original_hash['payload']['commits'].map{|c| c['sha']}.join(','),
#     :repo_name => original_hash['repo']['name'],
#     :push_id => original_hash['payload']['push_id'],
#   }
# }

# processed.deep_merge(new_data)
