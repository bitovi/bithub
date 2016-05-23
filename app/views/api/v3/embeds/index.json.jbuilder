json.array! @hubs do |e|
  json.partial! 'api/v3/hubs/hub', hub: e
end
