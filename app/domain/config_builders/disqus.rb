module ConfigBuilders
  class Disqus < Generic
    def config
      forums = 
      {
        token: brand_identity.andand.data[:access_token],
        forums: (feed_config.config.andand['forums'] || []).map{|p| p['id']}
      }
    end
  end
end
