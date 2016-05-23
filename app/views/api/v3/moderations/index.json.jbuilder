json.set! :data do
  json.array! @bits do |e|
    json.cache! ["v3/brands/#{@hub.brand.id}/hubs/#{@hub.id}", e] do
      json.partial! "api/v3/moderations/bit", bit: e, visibility: @visibility
    end
  end
end
