class User < ActiveRecord::Base
	devise :invitable, :database_authenticatable, :registerable,
	     :recoverable, :rememberable, :trackable, :validatable,
	     :omniauthable, :confirmable, :invitable

	rolify :role_cname => 'UserRole'

	has_many :organizations, through: :user_organizations
	has_many :user_organizations, dependent: :destroy

	attr_accessor :current_password

	def is_member_of_organization(organization_id)
		return organizations.where({id: organization_id}).length > 0	
	end

	def brand_ids
		organizations.map do |o|
		  o.brand_ids
		end.uniq.flatten
	end

	def brands
		organizations.map do |o|
		  o.brands
		end.uniq.flatten
	end
	
	def as_json options = {}
		super options.merge only: [ :id, :name, :created_at, :updated_at, :email ]
	end
end
