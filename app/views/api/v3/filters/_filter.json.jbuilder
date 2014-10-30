json.(filter, :id, :is_conj, :classification)

json.queries do
  json.array! filter.natlang_queries do |c|
    json.attr c.attr
    json.op c.op
    json.val c.val
  end
end
