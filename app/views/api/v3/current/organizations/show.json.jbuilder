json.partial! 'api/v3/current/organizations/organization', organization: @organization

json.set! :users do
  json.array! @organization.user_organizations.accepted.map(&:user) do |acc|
    json.partial! "api/v3/current/users/user", user: acc
  end
end

json.set! :invitations do
  json.array! @organization.user_organizations.pending.map(&:user) do |acc|
    json.partial! "api/v3/current/users/user", user: acc
  end
end
