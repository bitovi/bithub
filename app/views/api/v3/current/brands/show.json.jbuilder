json.partial! "api/v3/current/brands/brand", brand: @brand

json.set! :identities do
  json.array! @brand.identities do |identity|
    json.partial! "api/v3/current/brand_identities/brand_identity", brand_identity: identity
  end
end

