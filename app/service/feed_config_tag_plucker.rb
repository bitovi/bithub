class FeedConfigTagPlucker

  def initialize(params)
    @params = params
  end

  def create_tags
    tags.andand.each do |t|
      Tag.register t, 'keywords'
    end
  end

  def tags
    method_name = "tags_from_#{@params['feed_name']}".to_sym
    if respond_to? method_name
      send method_name
    end
  end

  def tags_from_github
    taggify (config.fetch('orgs') || []) + (config.fetch('repos') || [])
      .map{|repo_name| repo_name.gsub(/.+\//, '')}
  end

  def tags_from_meetup
    taggify config['groups'].map {|el| el['name']}
  end

  def tags_from_facebook
    taggify config['pages'].map {|p| p['name']}
  end

  def tags_from_rss
    taggify (config.fetch('sites') || []).map {|site| site['name']}
  end

  def tags_from_disqus
    taggify config['forums'].map {|f| f['id']}
  end

  def tags_from_twitter
    taggify config['terms']
  end

  def tags_from_stackexchange
    taggify config['tags']
  end

  private

  def taggify(tags)
    tags.map {|t| t.snake_case} unless tags.nil?
  end

  def config
    @params.fetch('config')
  end
end
