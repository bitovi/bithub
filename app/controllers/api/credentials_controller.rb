class Api::CredentialsController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter
	
	before_action :ensure_current_user
	before_action :ensure_organization_param_exists
	before_action :ensure_organization_member
	before_action :sanitize_params

	def index
		render json: { data: filter(Credential, params) }, status: :ok
	end

	def destroy
		Credential.find(params[:id]).destroy!
		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 "Credential, with id: '#{params[:id]}', was not found"
	end
end