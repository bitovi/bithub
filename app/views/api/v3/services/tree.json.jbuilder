json.brands @brands do |b|
  json.name b.name
  json.embeds b.embeds do |e|
    json.name e.name
    json.services e.services do |s|
      json.feed_name s.feed_name
      json.type_name s.type_name
      json.merge! s.service_config.data
    end
  end
end
