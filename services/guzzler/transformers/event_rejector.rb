require 'guzzler/transformers/api'
require 'guzzler/digest_set'

module Guzzler
  class EventRejector
    def call(items, service)
      Guzzler::DigestSet.reject_old(items, service)
    end
  end
end
