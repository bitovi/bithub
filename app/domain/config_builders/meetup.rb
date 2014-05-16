module ConfigBuilders
  class Meetup < Generic
    def config
      {
        token: brand_identity.data.andand[:access_token],
        groups: (feed_config.config.andand['groups'] || []).map{|g| g['id']},
        terms: terms || []
      }
    end
  end
end
