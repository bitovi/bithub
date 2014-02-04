module Events
  module Github

    class Watch < Protocol
      include Events::Github::Accessors::Standard

      def watch_id
        origin_event_id
      end

      def content_digest
        seed = origin_author_name + repo_name
        calc_digest(seed)
      end

    end
  end
end
