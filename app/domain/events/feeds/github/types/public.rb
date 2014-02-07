module Events
  module Github

    class Public < Protocol
      include Events::Github::Accessors::Standard

      def public_id
        origin_event_id
      end

      def content_digest
        seed = actor_login + repo_name
        calc_digest(seed)
      end
    end

  end
end
