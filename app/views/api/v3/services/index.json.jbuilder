json.array! @services do |c|
  json.partial! 'api/v3/services/_service', service: s
end
