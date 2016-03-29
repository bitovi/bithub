class Api::BaseController < ActionController::Base	
	include Devise::Controllers::Helpers
	
	respond_to :json
	
	def render_error_message e, m, status
		return render json: { message: m, errors: e }, status: status
	end
	
	def ensure_current_account
		return if current_account
		return must_be_authenticated
	end
	
	def ensure_auth_params_exists
		return unless params[:email].blank? || params[:password].blank?
		return invalid_login_attempt
	end
	
	def must_be_authenticated
		render json: {
			message: "You must authenticate prior to requesting this resource"
		}, status: :forbidden
	end
	
	def invalid_login_attempt
		render json: { 
			message: "We were unable to log you in. Please double-check your email and password."
		}, status: :bad_request
	end
	
	def sanitize_params
		params.permit!
	end
end
