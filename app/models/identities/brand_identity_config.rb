module Identities

  class BrandIdentityConfig

    attr_reader :data

    def initialize(source_data, provider_name)
      @data = source_data
      @provider_name = provider_name
    end

    def builder_class
      ::Identities::Builders.const_get(@provider_name.camel_case, false)
    end

    def builder
      @builder ||= builder_class.new(@data)
    end

    def build
      @data = builder.build
      self
    end

    def suggestions(type=nil)
      builder.suggestions(type)
    end

    def credentials(argument = nil)
      builder.credentials(argument)
    end

  end
end
