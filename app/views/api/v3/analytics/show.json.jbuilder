json.partial! 'api/v3/analytics/source', source: @source
json.timepoints @timepoints, :volume, :delta, :measured_at
