json.set! :data do 
  json.array! @countries do |c|
    json.partial! "api/countries/country", country: c
  end
end
