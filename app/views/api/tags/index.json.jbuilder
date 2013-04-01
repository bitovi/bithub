json.set! :data do 
  json.array! @tags do |t|
    json.partial! "api/tags/tag", tag: t
  end
end
