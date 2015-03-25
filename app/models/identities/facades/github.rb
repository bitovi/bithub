module Identities
  module Facades
    class Github < Facade::Protocol

      def repo_ids_and_names
        repo_names.map do |r|
          { id: r, name: r }
        end
      end

      def org_ids_and_names
        org_names.map do |o|
          { id: o, name: o }
        end
      end
      
      def repo_names
        repos.map {|r| r[:full_name]}
      end

      def org_names
        orgs.map {|o| o[:login]}
      end

      def repos
        @data.fetch(:repos)
      end

      def orgs
        @data.fetch(:orgs)
      end
    end
  end
end
