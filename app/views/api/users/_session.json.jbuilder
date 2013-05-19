json.(user, :id, :name, :email, :avatar_url, :score, :rank, :address, :city, :postal, :country, :activities, :identities)

json.admin user.has_role? :admin