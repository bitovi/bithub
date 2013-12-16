module Events
  module Github
    class Push

      def touches
        [Entities::Github::Issue, Entities::Github::PullRequest]
      end
    end
  end
end
