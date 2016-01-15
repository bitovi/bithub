require 'events/events'
require 'guzzler/transformers/api'

module Guzzler
  class EventDecorator

    def call(items, service)
      items_1 = decorate_rss(items, service)
      decorate_all(items_1, service)
    end

    def decorate_all(items, service)
      items.each do |item|
        item[:meta][:feed_name] = service.feed_name
        item[:meta][:type_name] = service.type_name
        item[:meta][:service_id] = service.service_id
        item[:meta][:embed_id] = service.embed_id
        item[:meta][:brand_id] = service.brand_id
        item[:meta][:tenant_name] = service.tenant_name
      end
      items
    end

    def decorate_rss(items, service)
      return items if service.feed_name != 'rss'

      items.map do |item|
        item[:meta][:source_url] = service.config.fetch(:url)
        item
      end
    end
  end
end
