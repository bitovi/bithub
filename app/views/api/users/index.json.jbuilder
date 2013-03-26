json.array! @users do |u|
  json.partial! "api/users/user", user: u
end
