json.(account_organization, :id, :invitation_created_at, :invitation_accepted_at)

json.account do
  json.(account_organization.account, :id, :name, :email)
end

json.invited_by do
  json.(account_organization.invited_by, :id, :name, :email) if account_organization.invited_by
end
