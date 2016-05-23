json.count @count

json.set! :data do
  json.array! @bits do |e|
    json.cache! ["v4/brands/#{@hub.brand.id}/hubs/#{@hub.id}", e] do
      json.partial! "api/v4/moderations/bit", bit: e, visibility: @visibility
    end
  end
end
