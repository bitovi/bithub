json.session_id session[:session_id]
json.profile do
  json.(@profile, :name, :email, :avatar_url)
end
