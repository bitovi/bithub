module Events
  module Github

    class Create < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Refs

      def create_id
        origin_event_id
      end

      def content_digest
        seed = actor_login + repo_name + ref_type + ref.to_s
        calc_digest(seed)
      end
    end

  end
end
