json.array!(@interactions) do |interaction|
  json.extract! interaction, :id, :event_type, :generated_by_id, :generated_by_type, :created_at
end
