class Configurator
  DefaultEnv = 'development'

  def initialize(env)
    @env = env
    @config = YAML::load_file(File.join(RootDir, 'config', 'services', 'crawler', "#{@env}.yml"))
  end
  attr_reader :config

  def brand_config(brand_name)
    @config.fetch(brand_name)
  end
  
  def feed_config(brand_name, feed_name)
    @config.fetch(brand_name).fetch(feed_name)
  end

  private
  def environment
    @env || DefaultEnv
  end
end
