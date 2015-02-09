json.(entity, :id, :title, :body, :feed_name, :type_name, :url, :images, :created_at, :updated_at)

json.thread_updated_ts entity.thread_updated_ts.to_i
json.thread_updated_at entity.thread_updated_ts

json.author do
  json.id entity.props['origin_author_name']
  json.avatar_url entity.props['origin_author_avatar_url']
end

json.service_ids entity.services.map {|s| s.id}

if relation
  json.is_approved relation.is_approved
  json.is_pinned relation.is_pinned
end
