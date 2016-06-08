class Api::CredentialsController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter
	
	before_action :ensure_current_user
	before_action :sanitize_params

	def index
		render json: filter(Credential, merge_brand_with_params), status: :ok
	end

	def destroy
		Credential.find(params[:id]).destroy!
		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 "Credential, with id: '#{params[:id]}', was not found"
	end

	protected

	def merge_brand_with_params
		brand = Brand.where({ tenant_name: session[:tenant_name] })
		return (params[:where] || {}).merge({ "brand_id" => brand.first.id })
	end
end