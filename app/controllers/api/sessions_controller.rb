class Api::SessionsController < Api::BaseController
	include Api::Helpers::Common

    before_action :ensure_auth_params_exists,	only: [ :create ]
	before_action :ensure_current_user,      	only: [ :index, :destroy ]

    def create
		return render json: session if current_user
    	
		resource = User.find_for_database_authentication email: params[:email]
		return invalid_login_attempt unless resource
		
		if resource.valid_password? params[:password]
			sign_in :user, resource
			return render json: session, status: :created
		end
		invalid_login_attempt
	end
	
	def index
		return render json: { data: session }, status: :ok
	end

    def destroy
		sign_out :user
		render json: { }, status: :ok
    end
end
