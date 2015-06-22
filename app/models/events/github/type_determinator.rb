module Events
  module Github
    class TypeDeterminator < Events::TypeDeterminator
      Mappings = { :IssuesEvent => :IssueEvent }

      def type_class
        super do
          if Github.constants.include?(remapped_type_name)
            @type_class = Github.const_get(remapped_type_name)
          end
        end
      end

      def remapped_type_name
        @mappings ||= Hash.new(type_name).merge!(Mappings)
        @mappings[type_name]
      end

      def type_name
        if github_event?
          source_data[:type].camel_case.to_sym
        elsif github_issue?
          :CustomIssueEvent
          # elsif github_pull_request?
          #   :CustomPullRequestEvent
        end
      end

      private
      def github_event?
        not(source_data[:type].nil?)
      end

      def github_issue?
        not(source_data[:labels].nil?)\
          && not(source_data[:state].nil?)\
          && not(source_data[:comments].nil?)
      end

      # def github_pull_request?
      #   not(source_data[:labels].nil?)\
      #     && not(source_data[:state].nil?)\
      #     && not(source_data[:comments].nil?)
      # end
    end
  end
end
