module Subscriptions
  class PolicyChecker

    def initialize(subscription)
      @subscription = subscription
    end

    def can_create_brand?(organization)
      check 'brands', organization.brands.count
    end

    def can_create_embed?(brand)
      check 'embeds_per_brand', brand.embeds.count
    end

    def can_create_service?(embed, feed_name=nil, type_name=nil)
      if feed_name && type_name
        key   = "#{feed_name}_#{type_name}"
        count = embed.services.where(feed_name: feed_name, type_name: type_name).count

        check(key, count) && check('services_per_embed', embed.services.count)
      else
        check 'services_per_embed', embed.services.count
      end
    end

    private

    def check(attr, value)
      limit = limits[attr] || 0
      limit == 0 ? true : limit > value
    end

    def limits
      @subscription.plan.limits || {}
    end

    def features
      @subscription.plan.features || {}
    end
  end
end
