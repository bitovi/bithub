module Events
  module Github

    class IssueComment < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegators :@comment, :id, :origin_id
      attr_reader :ipr, :comment, :repo, :actor
      
      def digest_seed
        event_id + self.class.name
      end
      
      def wrap_reponse
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
        @ipr ||= if (i = payload[:issue])
                   Wrappers::Github::Issue.new(i)
                 elsif (pr = payload[:pull_request])
                   Wrappers::Github::PullRequest.new(pr)
                 end
        self
      end

    end

  end
end
