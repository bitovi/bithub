module Events
  module Github

    class Create < Protocol
      include Events::Github::Accessors
      include Events::Github::Accessors::Refs

      def digest_seed
        actor.login + repo.name + ref_type + ref + self.class.name
      end

    end
  end
end
