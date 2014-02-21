module Events
  module Github

    class Commit < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def initialize(payload, commit)
        @commit = Wrappers::Github::Commit.new(commit)
      end

      def_delegators :@commit,
        :sha,
        :message,
        :url,
        :author_name,
        :author_email,
        :references_to
    end
    
  end
end
