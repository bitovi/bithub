json.(event, :id, :title, :body, :origin_ts)

json.category event.category_name
json.feed event.feed_name
json.tags event.tag_names
