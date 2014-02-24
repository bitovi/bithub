module Events
  module Twitter

    class Follow < Protocol
      extend Forwardable

      def_delegator :@source, :id, :source_id
      def_delegator :@source, :screen_name, :source_screen_name

      def_delegator :@target, :id, :target_id
      def_delegator :@target, :screen_name, :target_screen_name
      
      alias_method :origin_author_id, :source_id
      alias_method :origin_author_name, :source_screen_name

      def digest_seed
        source_id.to_s + target_id.to_s + self.class.name
      end

      def origin_timestamp
        Time.parse(source_data.andand[:created_at]).utc
      end

      def validate_source_and_target
        if we_are_source? and not(we_are_target?)
          @errors += "Follow event - we should be the target, not the source"
          @context = [ { source: source }, { target: target } ]
          false
        end
      end

      def wrap_reponse_parts
        @source ||= Wrappers::Twitter::User.new(source_data.andand[:source])
        @target ||= Wrappers::Twitter::User.new(source_data.andand[:target])
      end

      private

      def we_are_target?
        %w(bitovi canjs javascriptmvc jquerypp stealjs funcunit bitovi_bithub).include? target_screen_name
      end

      def we_are_source?
        %w(bitovi canjs javascriptmvc jquerypp stealjs funcunit bitovi_bithub).include? source_screen_name
      end
    end

  end
end
