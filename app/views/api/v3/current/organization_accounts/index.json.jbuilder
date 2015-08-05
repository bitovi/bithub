json.set! :data do
  json.array! @organization_accounts do |oa|
    json.partial! 'api/v3/current/shared/account_organization', account_organization: oa
  end
end
