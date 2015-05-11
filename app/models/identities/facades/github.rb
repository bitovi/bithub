module Identities
  module Facades
    class Github < Facade::Protocol

      def property_id_name_pairs(type=nil)
        if type == 'repo'
          repo_ids_and_names
        elsif type == 'org'
          org_ids_and_names
        else
          []
        end
      end

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
        @extracted_data[:repos] || []
      end

      def orgs
        @extracted_data[:orgs] || []
      end
    end
  end
end
