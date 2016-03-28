class Api::UsersController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account, only: [ :show ]
	
	def create
		user = Account.new params_to_account_arguments params
		ActiveRecord::Base.transaction do
	        unless user.save
		        return render_error_message user.errors, user.errors, :unprocessable_entity
	        end
		end
		
		org_builder = Organizations::OrganizationBuilder.new user, params
		begin
			ActiveRecord::Base.transaction do
				org_builder.build.save!
			end
		rescue Organizations::OrganizationBuilder::BuildingError => e
			return render_error_message e, e, :unprocessable_entity
		rescue ActiveRecord::RecordInvalid => e
			return render_error_message e, e, :unprocessable_entity
		end

		sign_in :account, user
		return render json: user, status: :created
	rescue KeyError => e
		render_error_message e, e, :bad_request
    end
		
	def show
		return render json: filter(Account, sanitize_params), status: :ok
	end
	
	private
	
	def sanitize_params
		params.permit!
	end
	
	def params_to_account_arguments params
		{ 
			email: params.fetch(:email), 
			password: params.fetch(:password),
			confirmed_at: DateTime.now,
			confirmation_sent_at: DateTime.now
		}
	end
end
