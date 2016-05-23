class Api::UsersController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_user, only: [:index]
	
	def create	
		user = User.new params_to_user_arguments params
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

		sign_in :user, user
		return render json: user, status: :created
	rescue KeyError => e
		render_error_message e, e, :bad_request
	rescue => e
		render_error_message e, e, :bad_request
    end
		
	def index
		return render json: filter(User, sanitize(params)), status: :ok
	rescue => from
		return render_error_message from, from.message, :bad_request
	end
	
	private
	
	def render_error_message e, m, status
		return render json: { message: m, errors: e }, status: status
	end
	
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
