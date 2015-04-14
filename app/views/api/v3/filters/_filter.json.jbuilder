json.(filter, :id, :action, :embed_id)

json.natlang_queries do
  json.array! filter.natlang_queries do |c|
    json.id c.id
    json.attr_name c.attr_name
    json.op c.op
    json.val c.val
    json.is_negated c.is_negated
  end
end
