module Identities

  class BrandIdentityConfig

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

    def data(present = :raw)

      if present == :raw
        builder.data
      elsif present == :reduced
        builder.present
      elsif present == :credentials
        builder.credentials
      elsif present == :reduced_with_credentials
        builder.present_with_credentials
      else
        nil
      end

    end

  end
end
