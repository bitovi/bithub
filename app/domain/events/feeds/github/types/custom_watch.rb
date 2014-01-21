module Events
  module Github

    class CustomWatch
      include Constructable
      include Persistable

      def initialize(repo, identity)
        @repo = Repo.new(repo)
        @identity = identity
      end
      
      def source_data
        { identity: @identity, target: @repo }
      end

      def content_digest
        seed = identity.uid.to_s + repo.id.to_s
        calc_digest(seed)
      end
      
      def origin_author_id
        @identity.uid
      end

      def origin_author_name
        @identity.source_data[:nickname]
      end

      def title
        "started watching #{repo_name}"
      end

      def repo_name
        @repo[:name]
      end

      def repo_full_name
        @repo[:full_name]
      end

      def taggify_target_repo_name
        [@repo.name]
      end

      def origin_timestamp
        2.years.ago # TODO set to when?
      end

      class Repo
        def initialize(repo)
          @data = repo
        end

        def name
          @data.andand[:name]
        end
      end
    end
  end
end
