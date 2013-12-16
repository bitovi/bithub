module Events
  module Github
    class PullRequest

      def touches
        [Entities::Github::PullRequest]
      end

    end
  end
end
