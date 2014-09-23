module Entities
  module Services

    class FakeFollowFiller
      def initialize
        @twitter_api = ::Accounts::ThirdPartyUserInformer.new.twitter
        @redis = Redis.new(:url => ENV['REDIS_URL'])
      end

      def fill_missing
        if (delta = user_ids_with_missing_names - cache.keys) && not(delta.empty?)
          users = @twitter_api.users(delta)
          new_data = Hash[users.map do |u|
            [u.id, u.screen_name]
          end]
        end

        update_follows(cache.merge(new_data || {}))
        update_cache(new_data) if new_data

        user_ids_with_missing_names.count
      end

      def update_follows(data)
        data.each do |user_id, screen_name|

          if (ss = follows_with_missing_source_name.where("props -> 'origin_author_id' = :user_id", :user_id => user_id.to_s).all)

            ss.each do |s|
              s.props['origin_author_name'] = screen_name
              s.props_will_change!
              s.save
            end
          end

          if (ts = follows_with_missing_target_name.where("props -> 'target_id' = :user_id", :user_id => user_id.to_s).all)

            ts.each do |t|
              t.props['target_name'] = screen_name
              t.props_will_change!
              t.save
            end
          end
        end
      end

      def cache
        Hash[(@redis.keys "screen_name_cache*").map do |k|
          [k.gsub('screen_name_cache:','').to_i, @redis.get(k)]
        end]
      end

      def update_cache(new_data)
        new_data.map do |user_id, screen_name|
          @redis.set(redis_prefix + user_id.to_s, screen_name)
        end
      end

      def user_ids_with_missing_names
        sources = follows_with_missing_source_name\
          .pluck("props -> 'origin_author_id'").map{|id_str| id_str.to_i} || []
        
        targets = follows_with_missing_target_name\
          .pluck("props -> 'target_id'").map{|id_str| id_str.to_i} || []

        (sources + targets).uniq
      end
      
      def follows_with_missing_source_name
        follows.where("props -> 'origin_author_name' = ''")
      end
      
      def follows_with_missing_target_name
        follows.where("props -> 'target_name' = ''")
      end

      def follows
        Entity.where(:feed_name => 'twitter', :type_name => 'follow')
      end

      def name_from_cache(user_id)
        @redis.get(redis_prefix + user_id.to_s)
      end
      
      def present_in_cache?(id)
        name_from_cache(id).nil?
      end

      def redis_prefix
        "screen_name_cache:"
      end

    end
  end
end
