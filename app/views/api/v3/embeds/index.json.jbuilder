json.array! @embeds do |e|
  json.partial! 'api/v3/embeds/embed', embed: e
end
