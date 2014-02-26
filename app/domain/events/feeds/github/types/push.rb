module Events
  module Github

    class Push < Protocol
      include Events::Github::Accessors

      attr_reader :actor, :repo, :commits

      def digest_seed
        event_id + self.class.name
      end

      def push_id
        payload.fetch[:push_id]
      end

      def head
        payload.fetch[:head]
      end

      def commit_messages
        @commits.map(&:message)
      end

      def commit_shas
        @commits.map(&:sha)
      end

      def commit_shas_csv
        commit_shas.join(',')
      end

      def commit_by_sha(sha)
        @commits.select{|c| c.sha == sha}.andand.first
      end

      def wrap_reponse
        @actor ||= Wrappers::Github::User.new(source_data.fetch(:actor))
        @repo ||= Wrappers::Github::Repo.new(source_data.fetch(:repo))
        @commits = payload.fetch(:commits).map{|c| Wrappers::Github::Commit.new(c)}
        self
      end

      alias_method :origin_id, :push_id
    end

  end
end
