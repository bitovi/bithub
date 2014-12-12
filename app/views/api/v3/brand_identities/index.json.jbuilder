json.set! :data do
  json.array! @identities do |i|
    json.partial! "api/v3/brand_identities/brand_identity", brand_identity: i
  end
end