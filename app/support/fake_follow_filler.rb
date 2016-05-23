require 'redis-namespace'

module Support
  class FakeFollowFiller
    def initialize(redis_conn = nil)
      @twitter_api = ::Support::ThirdPartyApiAdapter.new.twitter

      @redis = Redis::Namespace.new(redis_prefix, redis: redis_conn)
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
      if (es = Bit.where(feed_name: 'twitter', type_name: 'follow').where("props -> 'origin_author_name' = '' OR props -> 'target_name' = ''").all) 

        es.each do |e|
          if (x_name = data[x_id = e.props['origin_author_id'].to_i])
            e.props['origin_author_name'] = x_name
          end

          if (y_name = data[y_id = e.props['target_id'].to_i])
            e.props['target_name'] = y_name
          end

          title_src = x_name ? ('@' + x_name) : ('UID' + x_id.to_s)
          title_tgt = y_name ? ('@' + y_name) : ('UID' + y_id.to_s)

          e.title = "#{title_src} followed #{title_tgt}"

          e.is_pending = false
          e.props_will_change!
          e.save
        end
      end
    end

    def cache
      Hash[(@redis.keys "*").map do |k|
        [k.to_i, @redis.get(k)]
      end]
    end

    def update_cache(new_data)
      new_data.map do |user_id, screen_name|
        @redis.set(user_id.to_s, screen_name)
      end
    end

    def user_ids_with_missing_names
      user_ids = []

      follows.where("props -> 'origin_author_name' = '' OR props -> 'target_name' = ''").all.map do |e|
        user_ids.push(e.props['origin_author_id'].to_i).push(e.props['target_id'].to_i)
      end

      user_ids.uniq
    end

    def follows_with_missing_source_name
      follows.where("props -> 'origin_author_name' = ''")
    end

    def follows_with_missing_target_name
      follows.where("props -> 'target_name' = ''")
    end

    def follows
      Bit.where(:feed_name => 'twitter', :type_name => 'follow')
    end

    def name_from_cache(user_id)
      @redis.get(user_id.to_s)
    end

    def present_in_cache?(id)
      name_from_cache(id).nil?
    end

    def redis_prefix
      'screen_name_cache'
    end
  end
end
