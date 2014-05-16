module ConfigBuilders
  class Github < Generic
    def config
      {
        access_token: brand_identity.data.andand[:access_token],
        repos: feed_config.config.andand['repos'] || [],
        orgs: feed_config.config.andand['orgs'] || []
      }
    end
  end
end
