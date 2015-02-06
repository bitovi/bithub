json.(service, :id, :feed_name, :type_name, :entity_count)

json.config service.service_config.data

if service.has_errors?
  json.error do
    json.(service.service_errors.last, :klass, :message)
  end
else
  json.error nil
end