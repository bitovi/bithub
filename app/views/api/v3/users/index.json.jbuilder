json.set! :data do
  json.array! @users do |a|
    json.partial! "api/v3/users/user", user: a
  end
end
