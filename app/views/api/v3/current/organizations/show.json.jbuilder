json.partial! 'api/v3/current/organizations/organization', organization: @organization

json.set! :accounts do
  json.array! @organization.account_organizations.accepted.map(&:account) do |acc|
    json.partial! "api/v3/current/accounts/account", account: acc
  end
end

json.set! :invitations do
  json.array! @organization.account_organizations.pending.map(&:account) do |acc|
    json.partial! "api/v3/current/accounts/account", account: acc
  end
end
