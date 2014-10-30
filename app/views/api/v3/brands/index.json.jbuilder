json.set! :data do
  json.array! @brands do |b|
    json.partial! "api/v3/brands/brand", brand: b
  end
end
