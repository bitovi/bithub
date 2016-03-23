class Api::SessionsController < Api::BaseController
    before_action :ensure_auth_params_exists, only: [ :create ]
	before_action :ensure_current_account, only: [ :show, :destroy ]

    def create
		return user_session if current_account
    	
		resource = Account.find_for_database_authentication email: params[:email]
		return invalid_login_attempt unless resource
		
		if resource.valid_password? params[:password]
			sign_in :account, resource
			return render json: { user: current_account }, status: :created
		end
		invalid_login_attempt
	end
	
	def show
		return user_session
	end

    def destroy
		sign_out :account
		render json: { }, status: :ok
    end

    protected
	
	def user_session
		render json: { user: current_account }, status: :ok
	end
	
	def ensure_auth_params_exists
		return unless params[:email].blank? || params[:password].blank?
		return invalid_login_attempt
	end
	
	def invalid_login_attempt
		render json: { 
			message: "We were unable to log you in. Please double-check your email and password."
		}, status: :bad_request
	end
end
