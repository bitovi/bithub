module ForumsSpecific
  def forums(original_hash, partly_processed_hash)
    partly_processed_hash
    .deep_merge(cons_origin_tss_hash(original_hash['pubDate']))
    .deep_merge({
      title: original_hash['title'],
      body: sanitize_body(original_hash['description']),
      url: original_hash['link'],
      meta: {
        type: original_hash['category'].snake_case,
        origin_author_name: original_hash['dc:creator'],
        category: original_hash['filter_term'],
      }
    })
  end
end
