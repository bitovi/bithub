class Api::OrganizationsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account
	
	def index
		return render json: filter(Organization, sanitize(params)), status: :ok
	end
end
