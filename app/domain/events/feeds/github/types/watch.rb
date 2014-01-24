module Events
  module Github

    class Watch < Protocol
      include Events::Github::Accessors::Standard

      def content_digest
        seed = origin_author_name + repo_name
        calc_digest(seed)
      end

    end
  end
end
