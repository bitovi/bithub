module Entities
  module Services

    class FakeFollowFiller
      def initialize
        @twitter_api = ::Accounts::ThirdPartyUserInformer.new.twitter
        @redis = Redis.new(:url => ENV['REDIS_URL'])
      end

      def fill_missing
        if (user_ids_with_missing_names & cache.keys).length != user_ids_with_missing_names.length
          users = @twitter_api.users(user_ids_with_missing_names - cache.keys)

          new_data = Hash[users.map do |u|
            [u.id, u.screen_name]
          end]
        end

        update_follows(cache.merge(new_data || {}))
        update_cache(new_data) if new_data

        follows_with_missing_name
      end

      def update_follows(data)
        data.each do |user_id, screen_name|
          e = follows_with_missing_name.where("props -> 'origin_author_id' = :user_id", :user_id => user_id.to_s).first
          e.props['origin_author_name'] = screen_name
          e.props_will_change!
          e.save
        end
      end

      def cache
        Hash[user_ids_with_missing_names.reject do |id|
          name_from_cache(id).nil?
        end.map do |id|
          [id.to_i, name_from_cache(id)]
        end]
      end

      def update_cache(new_data)
        new_data.map do |user_id, screen_name|
          @redis.set(redis_prefix + user_id.to_s, screen_name)
        end
      end
      
      def follows_with_missing_name
        follows.where("props -> 'origin_author_name' = ''")
      end

      def user_ids_with_missing_names
        follows.where("props -> 'origin_author_name' = ''").pluck("props -> 'origin_author_id'").map{|id_str| id_str.to_i}
      end
      
      def follows
        Entity.where(:feed_name => 'twitter', :type_name => 'follow')
      end

      def name_from_cache(user_id)
        @redis.get(redis_prefix + user_id.to_s)
      end

      def redis_prefix
        "screen_name_cache:"
      end

    end
  end
end
