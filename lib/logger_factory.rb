require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/datefileoutputter'

$root_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

class LoggerFactory

  def initialize(name, args={})
    @name = name
    @env  = args[:environment] || 'development'

    logger_config_data = YAML.load_file config_path

    log_cfg = Log4r::YamlConfigurator
    log_cfg["ENV"] = @env
    log_cfg["COMPONENT_NAME"] = @name
    log_cfg.decode_yaml(logger_config_data['log4r_config'])
  end

  def logger
    Log4r::Logger['component']
  end

  private

  def config_path
    path = File.join($root_dir, 'config', 'log4r', "#{@env}.yml")
    if File.exists?(path)
      path
    else
      raise "log4r config file not found"
    end
  end

end
