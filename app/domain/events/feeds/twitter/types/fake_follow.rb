module Events
  module Twitter

    class FakeFollow < Protocol

      def digest_seed
        source_id.to_s + target_id.to_s + self.class.name
      end

      def source_id
        source_data.fetch(:source).fetch(:id)
      end

      def target_id
        source_data.fetch(:target).fetch(:id)
      end

      def origin_timestamp
        Time.parse(source_data.fetch(:created))
      end

      alias_method :origin_author_id, :source_id
    end

  end
end
