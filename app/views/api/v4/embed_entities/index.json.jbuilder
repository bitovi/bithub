json.count @count

json.set! :data do
  json.array! @entities do |e|
    json.cache! ["v4/brands/#{@embed.brand.id}/embeds/#{@embed.id}", e] do
      json.partial! "api/v4/embed_entities/entity", entity: e, visibility: @visibility
    end
  end
end
