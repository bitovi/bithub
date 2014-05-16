module ConfigBuilders
  class Twitter < Generic
    def config
      {
        access_token: brand_identity.data.andand[:access_token],
        access_secret: brand_identity.data.andand[:access_secret],
        terms: terms || []
      }
    end
  end
end
