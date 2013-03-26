json.array! @activities do |act|
  json.partial! "api/activities/activity", activity: act
end
