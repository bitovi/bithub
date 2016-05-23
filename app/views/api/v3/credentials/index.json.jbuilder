json.set! :data do
  json.array! @identities do |i|
    json.partial! "api/v3/credentials/credential", credential: i
  end
end