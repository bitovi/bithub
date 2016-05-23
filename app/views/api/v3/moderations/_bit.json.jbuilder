json.(bit, :id, :title, :body, :feed_name, :type_name, :url, :images, :created_at, :updated_at)

json.thread_updated_ts bit.thread_updated_ts.to_i
json.thread_updated_at bit.thread_updated_ts

json.author do
  json.id bit.props['origin_author_name']
  json.avatar_url bit.props['origin_author_avatar_url']
end

json.service_ids bit.services.map{|s| s.id}

json.is_approved bit.is_approved
json.is_pinned bit.is_pinned
json.popularity bit.popularity

if bit.feed_name == 'twitter' && bit.type_name == 'tweet' && bit.has_quote?
  json.quoted_status bit.quoted_status
end
  
if bit.feed_name == 'twitter' && bit.type_name == 'tweet' && bit.has_retweet?
  json.retweeted_status bit.events.last.source_data['retweeted_status']
end

if bit.feed_name == 'meetup' && bit.type_name == 'event'
  json.location bit.location
  json.group_name bit.group_name
end
