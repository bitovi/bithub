module Events
  module Github

    class CommitComment < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Comments

      def comment_id
        payload.andand[:comment].andand[:id]
      end

      def commit_id
        payload.andand[:comment].andand[:commit_id]
      end

      def origin_id
        comment_id
      end

      def content_digest
        seed = "#{actor_login}#{repo_name}#{commit_id}#{comment_id}"
        calc_digest(seed)
      end

    end

  end
end
