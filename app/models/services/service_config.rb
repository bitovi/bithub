module Services
  class ServiceConfig

    attr_reader :errors

    def initialize(feed_name, type_name, config)
      @feed_name = feed_name
      @type_name = type_name
      @config    = config
      @validator = get_validator
      @errors    = []
    end

    def valid?
      if @validator
        @validator.new @config
        true
      else
        @errors.push({ type: :validator, msg: "Feed: #{@feed_name}, Type: #{@type_name}" })
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
      @errors.map {|e| "#{e[:type]} error: #{e[:msg]}" }.join('\n')
    end

    private

    def get_validator
      validators = Services::ConfigValidators
      feed = @feed_name.to_s.camelize
      type = @type_name.to_s.camelize

      if validators.const_defined?(feed, false) && validators.const_get(feed).const_defined?(type, false)
        validators.const_get(feed).const_get(type)
      end
    end

  end
end
