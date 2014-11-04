json.array! @services do |s|
  json.partial! 'api/v3/services/service', service: s
end
