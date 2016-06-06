module Subscriptions
  class PolicyChecker

    def initialize(subscription)
      @subscription = subscription
    end

    def can_create_brand?(organization)
      check 'brands', organization.brands.count
    end

    def can_create_hub?(brand)
      check 'hubs_per_brand', brand.hubs.count
    end

    def can_create_service?(hub, feed_name=nil, type_name=nil)
      if feed_name && type_name
        key   = "#{feed_name}_#{type_name}"
        count = hub.services.where(feed_name: feed_name, type_name: type_name).count

        check(key, count) && check('services_per_hub', hub.services.count)
      else
        check 'services_per_hub', hub.services.count
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
