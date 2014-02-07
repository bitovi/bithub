module Events
  module Github

    class Fork < Protocol
      include Events::Github::Accessors::Standard

      def fork_id
        origin_event_id
      end

      def content_digest
        seed = actor_login + repo_name
        calc_digest(seed)
      end

    end

  end
end
