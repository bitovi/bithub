module Events
  module Github

    class Push < Protocol
      include Events::Github::Accessors

      def origin_id
        push_id
      end

      def push_id
        payload.andand[:push_id]
      end

      def commits
        @cs = payload.andand[:commits].map{|c| Wrappers::Github::Commit.new(c)}
      end

      def commit_shas
        @cs.map(&:sha).compact
      end

      def commit_messages
        commits.map(&:message).compact
      end

      def commit_shas_csv
        commit_shas.join(',')
      end

      def referenced_issue_numbers
        commits.map(&:referenced_issue_numbers).flatten
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
