json.cache! ("v2" + custom_cache_key(entity)) do
	json.(entity, :id, :title, :body, :url, :thread_updated_ts, :created_at, :updated_at)

  json.feed entity.feed_name
  json.type entity.type_name
end
