json.(event, :id, :title, :body)

json.category event.category.name
json.feed event.feed.name

json.children event.children do |c|
  json.(c, :title, :body)
end

json.tags event.tags.map { |t| t.name }
