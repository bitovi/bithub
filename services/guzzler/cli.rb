require 'singleton'
require 'json'

require 'guzzler'
require 'util'

module Guzzler

  class CLI
    include Singleton

    def run
      require 'launcher'
      @launcher = Launcher.new
      @launcher.run
      sleep
    end
  end
end
