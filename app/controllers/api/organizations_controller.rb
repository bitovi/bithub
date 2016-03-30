class Api::OrganizationsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account
	
	def show
		return render json: filter(Organization, params), status: :ok
	end
end
