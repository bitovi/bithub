json.set! :data do
  json.array! @plans do |p|
    json.partial! 'api/v3/plans/plan', plan: p
  end
end
