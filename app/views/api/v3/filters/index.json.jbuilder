json.set! :data do
  json.array! @filters do |f|
    json.partial! 'api/v3/filters/filter', filter: f
  end
end
