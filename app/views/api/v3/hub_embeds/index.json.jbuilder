json.set! :data do
  json.array! @embeds do |p|
    json.partial! 'api/v3/hub_presets/embed', embed: p
  end
end
