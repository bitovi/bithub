module Events
  module Twitter
    class FakeFollow < Protocol
      extend Forwardable

      def_delegator :@source, :id, :source_id
      def_delegator :@source, :screen_name, :source_screen_name

      def_delegator :@target, :id, :target_id
      def_delegator :@target, :screen_name, :target_screen_name

      def digest_seed
        source_id.to_s + target_id.to_s + "Events::Twitter::Follow"
      end

      def created_at
        Time.parse(source_data.fetch(:created_at)).utc
      end

      def wrap_response
        @source ||= Wrappers::Twitter::User.new(source_data.andand[:source])
        @target ||= Wrappers::Twitter::User.new(source_data.andand[:target])
        self
      end
      attr_reader :source, :target

      alias_method :origin_author_id, :source_id
    end
  end
end
