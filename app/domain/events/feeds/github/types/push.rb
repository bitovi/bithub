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
        commits.map {|c| c.andand[:sha]}
      end

      def commit_messages
        commits.map {|c| c.andand['message']}
      end

      def commit_shas_csv
        commit_shas.join(',')
      end

      def referenced_repo_name
        repo_name
      end

      def head
        payload.andand[:head]
      end

      def referenced_number
        if md = commit_messages.join(' ').match(/#(\d*)/)
          md.andand[0]
        end
      end
    end

  end
end
