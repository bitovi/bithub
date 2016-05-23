json.partial! 'api/v3/current/users/user', user: @user

json.set! :organizations do
  json.array! @user.organizations do |org|
    json.partial! "api/v3/current/organizations/organization", organization: org
  end
end
