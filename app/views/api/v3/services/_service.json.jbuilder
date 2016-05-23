json.(service, :id, :feed_name, :type_name, :brand_idbit_id, :approved_by_default, :state)

json.bit_count service.bits.count
json.config service.service_config.data

if service.has_errors?
  json.error do
    json.(service.service_errors.last, :klass, :message)
  end
else
  json.error nil
end
