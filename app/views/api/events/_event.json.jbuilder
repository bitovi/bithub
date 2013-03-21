json.(event, :id, :title, :body, :origin_ts)

json.category event.category.name
json.feed event.feed.name

json.children event.children do |c|
  json.partial! "api/events/child_event", event: c
end

json.tags event.tags.map { |t| t.name }
