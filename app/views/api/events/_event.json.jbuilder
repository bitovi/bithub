json.(event, :id, :title, :body, :origin_ts, :origin_date, :url)

json.category event.category_name
json.feed event.feed_name
json.tags event.tag_names
json.actor event.actor

json.upvotes event.upvotes
json.anteups event.anteups
json.award_value event.award_value
json.awarded event.awarded

json.props event.ext_props

json.children EventDecorator.decorate_collection(event.children) do |c|
  json.partial! "api/events/child_event", event: c
end
