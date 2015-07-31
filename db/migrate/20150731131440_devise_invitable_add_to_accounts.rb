class DeviseInvitableAddToAccounts < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public'
      add_column(:accounts, :invitation_token, :string) unless column_exists?(:accounts, :invitation_token)
      add_column(:accounts, :invitation_created_at, :datetime) unless column_exists?(:accounts, :invitation_created_at)
      add_column(:accounts, :invitation_sent_at, :datetime) unless column_exists?(:accounts, :invitation_sent_at)
      add_column(:accounts, :invitation_accepted_at, :datetime) unless column_exists?(:accounts, :invitation_accepted_at)
      add_column(:accounts, :invitation_limit, :integer) unless column_exists?(:accounts, :invitation_limit)
      add_column(:accounts, :invitations_count, :integer, default: 0) unless column_exists?(:accounts, :invitations_count)

      if !column_exists?(:accounts, :invited_by_id) && !column_exists?(:accounts, :invited_by_type)
        add_reference(:accounts, :invited_by, polymorphic: true)
      end

      add_index(:accounts, :invitations_count) unless index_exists?(:accounts, :invitations_count)
      add_index(:accounts, :invitation_token, unique: true) unless index_exists?(:accounts, :invitation_token, unique: true)
      add_index(:accounts, :invited_by_id) unless index_exists?(:accounts, :invited_by_id)

      # And allow null encrypted_password and password_salt:
      change_column_null :accounts, :encrypted_password, true
    end
  end

  def down
    if Apartment::Tenant.current == 'public'
      remove_column(:accounts, :invitation_token) if column_exists?(:accounts, :invitation_token)
      remove_column(:accounts, :invitation_created_at) if clumn_exists?(:accounts, :invitation_created_at)
      remove_column(:accounts, :invitation_sent_at) if clumn_exists?(:accounts, :invitation_sent_at)
      remove_column(:accounts, :invitation_accepted_at) if clumn_exists?(:accounts, :invitation_accepted_at)
      remove_column(:accounts, :invitation_limit) if clumn_exists?(:accounts, :invitation_limit)
      remove_column(:accounts, :invitations_count) if clumn_exists?(:accounts, :invitations_count)

      if column_exists?(:accounts, :invited_by_id) && column_exists?(:accounts, :invited_by_type)
        remove_reference(:accounts, :invited_by, polymorphic: true)
      end

      remove_index(:accounts, :invitations_count) if index_exists?(:accounts, :invitations_count)
      remove_index(:accounts, :invitation_token, unique: true) if index_exists?(:accounts, :invitation_token, unique: true)
      remove_index(:accounts, :invited_by_id) if index_exists?(:accounts, :invited_by_id)

      change_column_null    :accounts, :encrypted_password, false
    end
  end
end
