class Api::SessionsController < Api::BaseController
    before_action :ensure_auth_params_exists,   only: [ :create ]
	before_action :ensure_current_account,      only: [ :show, :destroy ]

    def create
		return render json: user_session if current_account
    	
		resource = Account.find_for_database_authentication email: params[:email]
		return invalid_login_attempt unless resource
		
		if resource.valid_password? params[:password]
			sign_in :account, resource
			return render json: user_session, status: :created
		end
		invalid_login_attempt
	end
	
	def show
		return render json: user_session, status: :ok
	end

    def destroy
		sign_out :account
		render json: { }, status: :ok
    end
	
	def user_session
		organization = current_account.organizations.first
		session["organization_id"] = organization.id
		session["tenant_name"] = organization.brands.first.tenant_name
		return session
	end
end
