json.partial! 'api/v3/current/accounts/account', account: @account

json.set! :organizations do
  json.array! @account.organizations do |org|
    json.partial! "api/v3/current/organizations/organization", organization: org
  end
end
