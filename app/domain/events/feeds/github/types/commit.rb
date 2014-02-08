module Events
  module Github

    class Commit < Protocol
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
      
      def references
        message.scan(/#\d+/).map {|m| m.gsub('#','')}
      end
    end
    
  end
end
