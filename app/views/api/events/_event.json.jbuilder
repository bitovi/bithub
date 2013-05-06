json.(event, :id, :title, :body, :origin_ts, :origin_date, :url)

json.category event.category_name
json.feed event.feed_name
json.tags event.tag_names

json.upvotes event.upvotes
json.anteups event.anteups
json.award_value event.award_value

json.author event.author_deco
json.props event.props_deco

json.has_parent event.has_parent

json.actor event.actor					# deprecated, use props.origin_author_name

json.children EventDecorator.decorate_collection(event.children) do |c|
  json.partial! "api/events/event", event: c
end


