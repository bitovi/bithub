class Configurator
  DefaultEnv = 'development'

  def initialize(env)
    @env = env
  end

  def config(feed_name)
    YAML::load_file(File.join(RootDir, 'config', 'services', 'crawler', "#{environment}.yml")).fetch(feed_name)
  end

  private
  def environment
    @env || DefaultEnv
  end
end
