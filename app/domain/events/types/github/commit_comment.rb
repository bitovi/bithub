module Events
  module Github
    class CommitComment

      def touches
        [Entities::Github::CommitComment, Entities::Github::Push]
      end
    end
  end
end
