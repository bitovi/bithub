json.partial! 'api/v3/current/organizations/organization', organization: @organization

json.set! :accounts do
  json.array! @organization.accounts do |acc|
    json.partial! "api/v3/current/accounts/account", account: acc
  end
end
