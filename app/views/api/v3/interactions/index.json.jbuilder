json.array!(@data) do |interaction|
  if @zoom == 'detailed'
    json.extract! interaction, :created_at, :primary_source_id, :secondary_source_id, :event_type, :event_subtype, :volume
  elsif @zoom == 'rough'
    json.extract! interaction, :created_at, :primary_source_id, :event_type, :volume
  end
end
