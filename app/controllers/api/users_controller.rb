class Api::UsersController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action 	:sanitize_params
	before_action	:ensure_auth_params_exists, only: [ :create ]
	before_action 	:ensure_current_user, only: [ :index ]
	
	def create
		user = User.new params_to_user_arguments params
		ActiveRecord::Base.transaction do
			unless user.save
				return show_422 "Email has already been taken"
			end
		end
	
		begin
			org_builder = Organizations::OrganizationBuilder.new user, params
			ActiveRecord::Base.transaction do
				org_builder.build.save!
			end
		rescue Organizations::OrganizationBuilder::BuildingError => e
			show_422 e
		rescue ActiveRecord::RecordInvalid => e
			show_422 e
		end

		sign_in :user, user
		return render json: user, status: :created
	rescue => e
		show_400 e
    end
		
	def index
		return render json: filter(User, params), status: :ok
	rescue => e
		show_400 e
	end
	
	private
	
	def params_to_user_arguments params
		{ 
			email: params.fetch(:email), 
			password: params.fetch(:password),
			name: params.fetch(:name, nil),
			confirmed_at: DateTime.now,
			confirmation_sent_at: DateTime.now,
		}
	end
end
