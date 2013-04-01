json.set! :data do 
  json.array! @users do |u|
    json.partial! "api/users/user", user: u
  end
end
