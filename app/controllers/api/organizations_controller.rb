class Api::OrganizationsController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter
	
	before_action :ensure_current_user
	before_action :sanitize_params
	
	def index
		return render json: { data: filter(Organization, params) }, status: :ok
	end
	
	def show
		return render json: Organization.find(params[:id]), status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 "Organization, with id: '#{params[:id]}' was not found"
	end
	
	def update
		org = Organization.find(params[:id])
		org.update(params[:organization])
		return render json: org, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 "Organization, with id: '#{params[:id]}' was not found"
	rescue ActiveRecord::UnknownAttributeError => e
		show_400 e
	end
end
