json.set! :data do
  json.array! @entities do |e|
    json.partial! "api/v3/embed_entities/entity", entity: e, visibility: @visibility
  end
end
