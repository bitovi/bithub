class Api::BaseController < ActionController::Base	
	include Devise::Controllers::Helpers
	
	respond_to :json
	
	def render_error_message e, m, status
		return render json: { message: m, errors: e }, status: status
	end
	
	def ensure_current_account
		return if current_account
		return render json: {
			message: "You must authenticate prior to requesting this resource"
		}, status: :unauthorized
	end
	
	def ensure_auth_params_exists
		return unless params[:email].blank? || params[:password].blank?
		return render json: { 
			message: "We were unable to log you in. Please double-check your email and password."
		}, status: :bad_request
	end
    
    def sanitize params
        params.permit!
    end
end
