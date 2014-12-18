json.(entity, :id, :title, :body, :feed_name, :type_name, :url, :thread_updated_ts, :created_at, :updated_at)

json.author do
  json.id entity.props['origin_author_name']
  json.avatar_url entity.props['origin_author_avatar_url']
end

json.service_ids entity.services.map {|s| s.id}
