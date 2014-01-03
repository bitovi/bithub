def remove_prefix(repo_name)
  repo_name.gsub(/.*\//, '')
end

def repo_name(url)
  match_groups = url.match("\/repos\/(.*)\/issues\/\d*")
  match_groups.andand[1]
end

def log_key_attrs(event_hash)
  $log.info "hk =============> #{event_hash['hash_key']}"
  $log.info "meta-feed ======> #{event_hash['meta'].andand['feed']}"
  $log.info "meta-category ==> #{event_hash['meta'].andand['category']}"
end
