json.array! @events do |event|
  json.title event.title
  json.body event.body
end
