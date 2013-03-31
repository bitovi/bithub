json.set! :data do 
  json.array! @events do |event|
    json.partial! "api/events/event", event: event
  end
end
