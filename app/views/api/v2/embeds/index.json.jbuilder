json.array! @embeds do |e|
  json.partial! 'api/v2/embeds/embed', embed: e
end
