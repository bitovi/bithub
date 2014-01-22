module Events
  module Github

    class Commit
      include Constructable
      include Persistable
      include Events::Github::Accessors::Standard

      def initialize(persistor, payload, commit)
        @persistor = persistor
        @data = symbolize_keys(payload)
        @commit = symbolize_keys(commit)
      end

      def sha
        @commit.andand[:sha]
      end

      def message
        @commit.andand[:message]
      end

      def url
        @commit.andand[:url]
      end

      def author_name
        @commit.andand[:name].andand[:name]
      end
      
      def author_email
        @commit.andand[:name].andand[:email]
      end
    end
    
  end
end
