module Events
  module Github

    class Push < Protocol
      include Events::Github::Accessors

      def digest_seed
        event_id + self.class.name
      end

      def origin_id
        push_id
      end

      def push_id
        payload.andand[:push_id]
      end

      def head
        payload.andand[:head]
      end

      def commit_messages
        @commits.map(&:message)
      end

      def commit_shas
        @commits.map(&:sha)
      end

      def commit_by_sha(sha)
        @commits.select{|c| c.sha == sha}.andand.first
      end

      def wrap_reponse_parts
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @commits = payload.andand[:commits].map{|c| Wrappers::Github::Commit.new(c)}
      end
    end

  end
end
