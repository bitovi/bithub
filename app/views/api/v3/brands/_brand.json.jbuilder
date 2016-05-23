json.(brand, :id, :name, :tenant_name)

json.set! :identities do
  json.array! brand.identities do |identity|
    json.partial! "api/v3/credentials/credential", credential: identity
  end
end
