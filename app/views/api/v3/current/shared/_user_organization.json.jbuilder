json.(user_organization, :id, :invitation_created_at, :invitation_accepted_at)

json.user do
  json.(user_organization.user, :id, :name, :email)
end

json.invited_by do
  json.(user_organization.invited_by, :id, :name, :email) if user_organization.invited_by
end
