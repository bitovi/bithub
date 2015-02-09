json.set! :data do
  json.array! @presets do |p|
    json.partial! 'api/v3/embed_presets/preset', preset: p
  end
end
