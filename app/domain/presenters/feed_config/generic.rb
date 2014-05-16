module Presenters
  module FeedConfig
    class Generic
      attr_reader :feed_config, :brand_identity

      def initialize(feed_config, brand_identity)
        @feed_config    = feed_config
        @brand_identity = ::BrandIdentityDecorator.new(brand_identity)
      end

      def terms
        terms = ([] << brand_identity.brand.name)
        terms += (brand_identity.brand.keywords || []) & (feed_config.config.andand['terms'] || feed_config.config.andand['tags'] || [])
        terms.uniq
      end

      def config
        {}
      end

      def is_valid?
        feed_config.valid_config?
      end
    end

  end
end
