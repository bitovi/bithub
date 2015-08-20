json.(entity, :id, :title, :body, :feed_name, :type_name, :url, :images, :created_at, :updated_at)

json.thread_updated_ts entity.thread_updated_ts.to_i
json.thread_updated_at entity.thread_updated_ts

json.author do
  json.id entity.props['origin_author_name']
  json.avatar_url entity.props['origin_author_avatar_url']
end

json.service_ids entity.services.map{|s| s.id}

json.is_approved entity.is_approved
json.is_pinned entity.is_pinned
json.popularity entity.popularity

if entity.feed_name == 'twitter' && entity.type_name == 'tweet' && entity.has_quote?
  json.quoted_status entity.quoted_status
end
  
if entity.feed_name == 'twitter' && entity.type_name == 'tweet' && entity.has_retweet?
  json.retweeted_status entity.events.last.source_data['retweeted_status']
end
