def log_key_attrs(event_hash)
  $log.info "hk =============> #{event_hash['hash_key']}"
  $log.info "meta-feed ======> #{event_hash['meta'].andand['feed']}"
  $log.info "meta-category ==> #{event_hash['meta'].andand['category']}"
end

def logit(logger, error, payload)
end
