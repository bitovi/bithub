module ConfigBuilders
  class Rss < Generic
    def config
      { urls: feed_config.config.andand['urls'] || [] }
    end
  end
end
