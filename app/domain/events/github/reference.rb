module Events
  module Github

    class Reference

      def self.scan_for_refs(text)
        text.scan(/([a-zA-Z0-9_\-\/]*)#(\d+)/).map {|rn, num| self.new(rn, num)}
      end

      def initialize(repo_name, number)
        @rn = repo_name
        @num = number
      end

      def repo_name
        @rn
      end

      def number
        @num
      end

    end

  end
end
