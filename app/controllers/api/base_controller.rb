class Api::BaseController < ActionController::Base	
	include Devise::Controllers::Helpers
	
	respond_to :json
	
	def render_error_message e, m, status
		return render json: { message: m, errors: e }, status: status
	end
	
	def ensure_current_account
		return if current_account
		render json: {
			message: "You must authenticate prior to requesting this resource"
		}, status: :unauthorized
	end
end
