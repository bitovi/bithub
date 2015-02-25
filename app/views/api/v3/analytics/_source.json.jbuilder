if source.is_a? Embed
  json.partial! 'api/v3/embeds/embed', embed: source
elsif source.is_a? Service
  json.partial! 'api/v3/services/service', service: source
end
