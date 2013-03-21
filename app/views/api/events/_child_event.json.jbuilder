json.(event, :id, :title, :body, :origin_ts)

json.category event.category.name
json.feed event.feed.name

json.tags event.tags.map { |t| t.name }
