class Api::BaseController < ActionController::Base	
	include Api::Helpers::Common
	include Api::Helpers::Filter

	include Devise::Controllers::Helpers
	
	respond_to :json
	
	rescue_from ActiveRecord::AssociationNotFoundError do |e|
		show_400 e
	end
	
	def ensure_current_user
		return if current_user
		must_authenticate_before
	end

	def ensure_organization_member
		return if current_user.is_member_of_organization params[:organization_id]
		show_401 "You are not a member of the provided organization"
	end
	
	def ensure_auth_params_exists
		return unless params[:email].blank? || params[:password].blank?
		invalid_login_attempt
	end

	def ensure_organization_param_exists
		return unless params[:organization_id].blank?
		requires_organization_parameter
	end

	def must_authenticate_before
		show_401 "You must authenticate prior to requesting this resource"
	end

	def invalid_login_attempt
		show_400 "We were unable to log you in. Please double-check your email and password."
	end

	def requires_organization_parameter
		show_400 "This request requires an organization_id be present as a parameter"
	end

	def switch_tenant
		tenant = Brand.where({ organization_id: params[:organization_id] }).first.tenant_name
		Apartment::Tenant.switch!(tenant)
	end

	def switch_to_public_schema
		Apartment::Tenant.switch!
	end
    
	def sanitize_params
		params.permit!
	end
end
