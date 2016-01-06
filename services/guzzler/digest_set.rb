require 'digest/md5'

module Guzzler
  class DigestSet
    def self.reject_old(events, service)
      return events if events.empty?

      key_total = key_total(service); key_batch = key_batch(service)
      
      digests = events.map {|e| e[:meta][:content_digest]}
      new_digests = []

      Guzzler.redis do |conn|
        conn.sadd(key_batch, digests) # store the new batch to a set
        conn.sdiffstore(key_batch, key_batch, key_total) # remove seen events from the new batch
        conn.sunionstore(key_total, key_batch, key_total) # store the unseen events into the set of seen events
        new_digests = conn.smembers(key_batch) # get the new events
      end

      events.select { |e| new_digests.include?(e[:meta][:content_digest]) }
    end

    def self.key_total(service)
      (%w(digests total) + [ service.tenant_name, service.service_id ]).join(':')
    end

    def self.key_batch(service)
      (%w(digests batch) + [ service.tenant_name, service.service_id ]).join(':')
    end
  end
end
