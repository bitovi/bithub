module Services
  class ServiceConfig

    def initialize(feed_name, type_name, config)
      @feed_name = feed_name
      @type_name = type_name
      @errors    = []
      @config    = virtus_class.new(config)
    rescue => e
      @errors.push({ klass: e.class, message: e.message })
    end
    attr_reader :config, :errors

    def data
      @config.to_h if valid?
    end

    def valid?
      @errors.empty?
    end

    def humanize(brand_ident)
      @config.humanized_name = brand_ident.config.humanized_name(@config.id) if @config.respond_to?(:'humanized_name=')
      @config
    end

    def error_msg
      res = @errors.reduce({}) do |memo, e|
        memo[e[:attr]] = [] if memo[e[:attr]].nil?
        memo[e[:attr]] << e[:msg]
        memo
      end
      Rails.logger.info res
      res
    end

    private

    def virtus_class
      validators = Services::ConfigTypes
      feed = @feed_name.to_s.camelize
      type = @type_name.to_s.camelize

      if validators.const_defined?(feed, false) && validators.const_get(feed).const_defined?(type, false)
        validators.const_get(feed).const_get(type)
      else
        fail ArgumentError.new("Unknown feed/type, feed: #{feed}, type: #{type}" )
      end
    end

  end
end
