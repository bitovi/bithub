class FeedConfigDecorator < ::Draper::Decorator
  delegate :id, :brand, :feed_name

  def config
    @bids = BrandIdentityDecorator.decorate_collection(
      source.brand.identities.where(:provider => source.feed_name).all
    )

    build_method = "#{source.feed_name}_config".to_sym
    if source.valid_config? && respond_to?(build_method)
      send(build_method)
    end
  end

  def brand_name
    source.brand.name
  end

  def github_config
    {
      access_token: @bids.first.data.andand[:access_token],
      repos: source.config.andand['repos'] || [],
      orgs: source.config.andand['orgs'] || []
    }
  end

  def facebook_config
    {
      token: @bids.first.data.andand[:access_token],
      pages: source.config.andand['pages'] || []
    }
  end

  def foursquare_config
    {
      venues: source.config
      .andand['venues']
      .map do |venue|
        Hash[:id, v['id']]
      end || []
    }
  end

  def disqus_config
    {
      token: @bids.first.data.andand[:access_token],
      forums: source.config
      .andand['forums']
      .map do |page|
        page['id']
      end
    }
  end

  def meetup_config
    {
      terms: terms || [],
      token: @bids.first.data.andand[:access_token],
      groups: source.config
      .andand['groups']
      .andand.map do |group|
        group['id']
      end || []
    }
  end

  def twitter_config
    {
      terms: terms || [],
      identities: @bids.map do |id|
        {
          access_token: id.data.andand[:access_token],
          access_secret: id.data.andand[:access_secret],
        }
      end
    }
  end

  def stackexchange_config
    {
      token: @bids.first.data.andand[:access_token],
      terms: (brand_keywords & feed_config_keywords) || []
    }
  end

  def rss_config
    { sites: source.config.andand['sites'] || [] }
  end

  def irc_config
    source.config
  end

  private

  def terms
    #([source.brand.name] + (brand_keywords & feed_config_keywords)).uniq
    feed_config_keywords.uniq
  end

  def brand_keywords
    source.brand.keywords || []
  end

  def feed_config_keywords
    feed_config_terms || feed_config_tags || []
  end

  def feed_config_terms
    source.config.andand['terms']
  end

  def feed_config_tags
    source.config.andand['tags']
  end
end
