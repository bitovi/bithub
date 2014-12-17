json.(entity, :id, :title, :body, :feed_name, :type_name, :url, :thread_updated_ts, :created_at, :updated_at)

json.service_ids entity.services.map {|s| s.id}
