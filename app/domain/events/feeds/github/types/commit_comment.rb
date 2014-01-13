module Events
  module Github

    class CommitCommentEvent
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Comments

      def commit_id
        payload.andand[:comment].andand[:commit_id]
      end

    end

  end
end
