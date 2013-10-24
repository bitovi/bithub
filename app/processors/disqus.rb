module DisqusSpecific

  def disqus(original_hash, partly_processed_hash)
    # Disqus provides date in format: "2013-02-14T22:47:29" !!! we append 'Z'

    partly_processed_hash
    .deep_merge(cons_origin_tss_hash { Time.parse(event['createdAt']+"Z").utc })
    .deep_merge({
      title: event['thread']['title'],
      body: event['message'],
      url: event['url'],
      meta: {
        feed: @feed,
        origin_author_name: event['author']['name'],
      }
    })
  end

end
