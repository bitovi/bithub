json.(event, :id, :title, :body, :origin_ts, :origin_date, :url)

json.category event.category_name
json.feed event.feed_name
json.tags event.tag_names

json.upvotes event.upvotes.count
json.award event.rule.award_value
json.anteups event.anteups.sum(:value)
json.awarded event.awards.first

json.children EventDecorator.decorate_collection(event.children) do |c|
  json.partial! "api/events/child_event", event: c
end
