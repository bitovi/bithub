json.(filter, :id, :action)

json.natlang_queries do
  json.array! filter.natlang_queries do |c|
    json.attr_name c.attr_name
    json.op c.op
    json.val c.val
  end
end
