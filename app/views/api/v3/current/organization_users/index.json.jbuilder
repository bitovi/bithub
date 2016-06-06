json.set! :data do
  json.array! @organization_users do |oa|
    json.partial! 'api/v3/current/shared/user_organization', user_organization: oa
  end
end
