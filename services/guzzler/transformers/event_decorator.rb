require 'events/events'
require 'guzzler/transformers/api'

module Guzzler
  class EventDecorator

    def call(items, fetch_job)
      items_1 = decorate_rss(items, fetch_job)
      decorate_all(items_1, fetch_job)
    end

    def decorate_all(items, fetch_job)
      items.each do |item|
        item[:meta][:feed_name] = fetch_job.feed_name
        item[:meta][:type_name] = fetch_job.type_name
        item[:meta][:service_id] = fetch_job.service_id
        item[:meta][:embed_id] = fetch_job.embed_id
        item[:meta][:brand_id] = fetch_job.brand_id
        item[:meta][:tenant_name] = fetch_job.tenant_name
      end
      items
    end

    def decorate_rss(items, fetch_job)
      return items if fetch_job.feed_name != 'rss'

      items.map do |item|
        item[:meta][:source_url] = fetch_job.config.fetch('url')
        item
      end
    end
  end
end
