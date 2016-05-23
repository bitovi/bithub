json.set! :data do
  json.array! @user_organizations do |ao|
    json.partial! 'api/v3/current/shared/user_organization', user_organization: ao
  end
end
