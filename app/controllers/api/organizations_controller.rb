class Api::OrganizationsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account
	before_action :sanitize_params
	
	def index
		return render json: filter(Organization, sanitize(params)), status: :ok
	end
	
	def show
		return render json: Organization.find(params[:id]), status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Organization, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	end
	
	def update
		org = Organization.find(params[:id])
		org.update(params[:organization])
		return render json: org, status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Organization, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	rescue ActiveRecord::UnknownAttributeError => e
		return render json: {
			message: e.message
		}, status: :bad_request
	end
	
	protected
	
	def sanitize_params
		sanitize params
	end
end
