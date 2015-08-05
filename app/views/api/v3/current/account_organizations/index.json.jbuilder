json.set! :data do
  json.array! @account_organizations do |ao|
    json.partial! 'api/v3/current/shared/account_organization', account_organization: ao
  end
end
