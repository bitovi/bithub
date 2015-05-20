json.set! :data do
  json.array! @entities do |e|
    json.cache! ['v3', e] do
      json.partial! "api/v3/embed_entities/entity", entity: e, visibility: @visibility
    end
  end
end
