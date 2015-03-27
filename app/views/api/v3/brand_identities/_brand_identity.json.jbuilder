json.cache! brand_identity do
  json.(brand_identity, :id, :provider, :uid, :brand_id)
  json.created_at_timestamp brand_identity.created_at.to_i
  json.name brand_identity.name
end
