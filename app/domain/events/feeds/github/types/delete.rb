module Events
  module Github

    class Delete < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Refs

      def digest_seed
        actor_login + repo_name + ref_type + ref.to_s + self.class.name
      end

    end
  end
end
