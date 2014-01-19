module Events
  module Github

    class Watch
      include Constructable
      include Events::Github::Accessors::Standard

      def content_digest
        seed = identity.uid.to_s + repo_id.to_s
        calc_digest(seed)
      end

      def title
        "started watching #{repo_name}"
      end

    end
  end
end
