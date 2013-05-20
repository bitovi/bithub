json.(user, :id, :name, :email, :avatar_url, :address, :city, :postal, :country, :activities, :identities)

json.score user.cached_score
json.admin user.has_role? :admin
