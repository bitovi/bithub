module Services
  class ServiceConfig

    def initialize(feed_name, type_name, config)
      @feed_name = feed_name
      @type_name = type_name
      @config    = config
      @errors    = []
    end
    attr_reader :errors

    def valid?
      @errors = []
      if validator_class
        validator_class.new @config
        true
      else
        @errors.push({ type: :validator, msg: "Unknown feed/type, feed: #{@feed_name}, type: #{@type_name}" })
        false
      end
    rescue Virtus::CoercionError => e
      @errors.push({ type: :coercion, attr: e.attribute_name, msg: e.message })
      false
    end

    def data
      @config if valid?
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

    def validator_class
      validators = Services::ConfigValidators
      feed = @feed_name.to_s.camelize
      type = @type_name.to_s.camelize

      if validators.const_defined?(feed, false) && validators.const_get(feed).const_defined?(type, false)
        validators.const_get(feed).const_get(type)
      end
    end

  end
end
