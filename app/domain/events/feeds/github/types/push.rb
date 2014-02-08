module Events
  module Github

    class Push < Protocol
      include Events::Github::Accessors::Standard

      def push_id
        payload.andand[:push_id]
      end

      def origin_id
        push_id
      end

      def commits
        payload.andand[:commits]
      end

      def commit_shas
        commits.map {|c| c.andand[:sha]}.compact
      end

      def commit_messages
        commits.map {|c| c.andand[:message]}.compact
      end

      def commit_shas_csv
        commit_shas.join(',')
      end

      def referenced_issue_numbers
        commit_messages.join(' ').scan(/#\d+/).uniq.map {|m| m.gsub('#','').to_s}
      end

      def referenced_repo_name
        repo_name
      end

      def head
        payload.andand[:head]
      end

      def commit_by_sha(sha)
        if commit_shas.include?(sha)
          commits.select {|c| c.andand[:sha] == sha}.first
        end
      end

    end

  end
end
