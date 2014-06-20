class AccountRole < ActiveRecord::Base
  has_and_belongs_to_many :accounts, :join_table => :accounts_account_roles
  belongs_to :resource, :polymorphic => true

  scopify
  # attr_accessible :title, :body
end
