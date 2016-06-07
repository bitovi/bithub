class Api::BaseController < ActionController::Base	
	include Api::Helpers::Common
	include Devise::Controllers::Helpers
	
	respond_to :json
	
	rescue_from ActiveRecord::AssociationNotFoundError do |e|
		show_400 e
	end
	
	def ensure_current_user
		return if current_user
		show_401 "You must authenticate prior to requesting this resource"
	end
	
	def ensure_auth_params_exists
		return unless params[:email].blank? || params[:password].blank?
		show_400 "We were unable to log you in. Please double-check your email and password."
	end

	def switch_tenant
		Apartment::Tenant.switch!(session[:tenant_name])
	end

	def switch_to_public_schema
		Apartment::Tenant.switch!
	end
    
	def sanitize_params
		params.permit!
	end
end
