module DisqusSpecific

  def disqus(original_hash, partly_processed_hash)
    # Disqus provides date in format: "2013-02-14T22:47:29" !!! we append 'Z'

    partly_processed_hash
    .deep_merge(cons_origin_tss_hash { Time.parse(original_hash['createdAt']+"Z").utc })
    .deep_merge({
      title: original_hash['thread']['title'],
      body: original_hash['message'],
      url: original_hash['url'],
      meta: {
        feed: 'disqus',
        origin_author_name: original_hash['author']['name'],
      }
    })
  end

end
