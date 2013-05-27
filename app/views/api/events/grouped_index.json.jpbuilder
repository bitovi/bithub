@decorated_events_in_groups.each do |category, events|
  json.set! category do
    json.array! events do |ev| 
      json.partial! "api/events/event", event: ev
    end
  end
end
