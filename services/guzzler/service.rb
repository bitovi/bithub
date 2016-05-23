require 'core_ext'

module Guzzler
  class Service

    # "guzzler:services:gauntless_forrest_3523:17/repo_issues"
    def initialize(service_key, service_data)
      @_service_key = service_key

      @tenant_name, service_id_string = service_key.gsub('guzzler:', '').gsub('services:', '').split(':')
      @service_id = service_id_string.to_i
      
      data = JSON.parse(service_data)

      @feed_name = data.fetch('feed_name')
      @type_name = data.fetch('type_name')
      @hub_id = data.fetch('hub_id')
      @brand_id = data.fetch('brand_id')
      @interval = data.fetch('interval')  { 60 }

      @config = data.fetch('config').symbolize_keys
    end

    attr_accessor :data

    attr_reader :tenant_name, :service_id, :hub_id, :brand_id,
      :interval, :feed_name, :type_name, :config
    
    def key
      "services:#{@tenant_name}:#{@service_id}"
    end

    def member
      "guzzler:" + key
    end

    def token
      @config['access_token'] || @config['token']
    end

    def fetcher_name
      multi_component_job? ? component_name : type_name
    end

    def component_name
      @component_name ||= @_service_key.split('/').last
    end

    def multi_component_job?
      @_service_key.include?('/')
    end

    def to_s
      "#{@tenant_name},#{@hub_id},#{@service_id},#{@feed_name},#{@type_name}"
    end

    def to_h
      {
        feed_name: @feed_name,
        type_name: @type_name,
        interval: @interval,
        config: @config
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
