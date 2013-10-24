module BlogSpecific
  def blog(original_hash, partly_processed_hash)
    partly_processed_hash
    .deep_merge(cons_origin_tss_hash { Time.strptime(original_hash['published'], "%e %b %Y").utc })
    .deep_merge({
      title: event['title'],
      url: event['link'],
      body: Sanitize.clean(event['description'], Sanitize::Config::RELAXED),
    })
  end
end
