json.brands @brands do |b|
  json.(b, :id, :name)
  json.embeds b.embeds do |e|
    json.(e, :id, :name)
    json.services e.services do |s|
      json.(s, :id, :feed_name, :type_name)
      json.merge! s.service_config.data
	  json.merge! s.credentials
    end
  end
end
