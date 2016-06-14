class Api::EmbedsController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter

	before_action :ensure_current_user
	before_action :sanitize_params
	before_action :ensure_organization_param_exists
	before_action :ensure_organization_member, only: [ :create ]
	before_action :ensure_embed_params, only: [ :create ]
	before_action :switch_tenant

	def create
		embed = HubEmbed.create!(embed_params)
		render json: embed, status: :created
	rescue => e
		show_400 e
	end

	def index
		return render json: { data: filter(HubEmbed, params) }, status: :ok
	ensure
		switch_to_public_schema
	end

	def show
		return render json: HubEmbed.find(params[:id]), status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 embed_not_found_for_id
	ensure
		switch_to_public_schema
	end

	def update
		embed = HubEmbed.find(params[:id]).update!(params[:embed])
		return render json: embed, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 embed_not_found_for_id
	rescue ActiveRecord::UnknownAttributeError => e
		show_400 e
	ensure
		switch_to_public_schema
	end

	def destroy
		HubEmbed.find(params[:id]).destroy!
		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 embed_not_found_for_id
	ensure
		switch_to_public_schema
	end

	protected

	def ensure_embed_params
		# required params: hub_id, permitted: name, config [live, theme]
		missing_params = ["hub_id"].reject do |key|
			params.key?(key) || params[key]
		end
		if missing_params.length > 0
			show_400 "Request is missing required parameters: #{missing_params.join ', '}."
		end
	end

	def embed_params
		params.reject {|k, v| ["action", "controller", "organization_id"].include? k}
	end

	def embed_not_found_for_id 
		"Embed, with id: '#{params[:id]}', was not found"
	end
end