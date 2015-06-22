module Events
  module Twitter
    class TypeDeterminator < Events::TypeDeterminator

      def type_class
        super do
          if Twitter.constants.include?(type_name)
            @type_class = Twitter.const_get(type_name)
          end
        end
      end

      def type_name
        if is_follow_event?
          :FollowEvent
        elsif is_fake_follow_event?
          :FakeFollowEvent
        elsif is_status_event?
          :TweetEvent
        elsif source_data[:custom_follow]
          :CustomFollowEvent
        end
      end

      def is_follow_event?
        (source_data[:event].andand == 'follow') && not(source_data[:source].nil?) && not(source_data[:target].nil?)
      end

      def is_fake_follow_event?
        (source_data[:event].andand == 'fake_follow') && not(source_data[:source].nil?) && not(source_data[:target].nil?)
      end

      def is_status_event?
        not(source_data[:text].nil?) && not(source_data[:user].andand[:screen_name].nil?)
      end

    end
  end
end
