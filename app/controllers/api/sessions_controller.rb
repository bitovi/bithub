class Api::SessionsController < Api::BaseController
    before_action :ensure_auth_params_exists,   only: [ :create ]
	before_action :ensure_current_account,      only: [ :show, :destroy ]

    def create
		return user_session if current_account
    	
		resource = Account.find_for_database_authentication email: params[:email]
		return invalid_login_attempt unless resource
		
		if resource.valid_password? params[:password]
			sign_in :account, resource
			return user_session :created
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
	
	def user_session(status = :ok)
		user = {}.merge(current_account.as_json)
		user[:tenant_name] = current_account.organizations.first.brands.first.tenant_name
		render json: user, status: status
	end
end
