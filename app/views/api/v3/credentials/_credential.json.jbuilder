json.(credential, :id, :provider, :uid, :brand_id)
json.created_at_timestamp credential.created_at.to_i
json.name credential.name
