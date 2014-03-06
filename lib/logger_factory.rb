require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/rollingfileoutputter'
require 'log4r/outputter/datefileoutputter'

class LoggerFactory
  ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  def initialize(name, env = 'development')
    @name = name; @env = env
    filename = (env == 'development' || env == 'test') ? 'log4r_dev.yml' : 'log4r.yml'
    @config_path = File.join(ROOT_DIR, 'config', filename)

    logger_config_data = YAML.load_file(@config_path)
    log_cfg = Log4r::YamlConfigurator
    log_cfg["ENV"] = @env
    log_cfg["COMPONENT_NAME"] = @name
    log_cfg.decode_yaml(logger_config_data['log4r_config'])
    @loggers = Log4r::Logger
  end

  def component_logger
    @loggers['component']
  end

  def ar_logger
    @loggers['active_record']
  end
  
  def ac_logger
    @loggers['action_controller']
  end
end
