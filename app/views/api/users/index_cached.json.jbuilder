json.set! :data do
  json.array! @users do |u|
    json.id u.user_id
	json.name u.user_name
	json.email u.user_email
	json.score u.user_score
	json.avatar_url u.user_gravatar_url
  end
end
