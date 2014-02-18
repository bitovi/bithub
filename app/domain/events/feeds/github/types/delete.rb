module Events
  module Github

    class Delete < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Refs

      def content_digest
        seed = actor_login + repo_name + ref_type + ref.to_s + self.class.name
        calc_digest(seed)
      end

    end
  end
end
