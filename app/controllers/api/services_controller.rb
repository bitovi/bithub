class Api::ServicesController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter

	before_action :ensure_current_user
	before_action :sanitize_params
	before_action :ensure_organization_param_exists
	before_action :ensure_organization_member, only: [ :create ]
	before_action :ensure_service_params, only: [ :create ]
	before_action :switch_tenant

	def create
		service = Service.new(service_params)
		service.save!
		return render json: service, status: :created
	rescue => e
		show_400 e
	ensure
		switch_to_public_schema
	end

	def index
		return render json: { data: filter(Hub, params) }, status: :ok
	ensure
		switch_to_public_schema
	end

	def update
		Service.find(params[:id]).update!(params[:service])
		return render json: service, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 service_not_found_for_id
	rescue ActiveRecord::UnknownAttributeError => e
		show_400 e
	ensure
		switch_to_public_schema
	end

	def destroy
		service = Service.find(params[:id])
		if service.clear_relations_and_destroy
      		CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)
      		render json: { }, status: :ok
    	end
	rescue ActiveRecord::RecordNotFound
		show_404 service_not_found_for_id
	rescue => e
		show_422 e
	ensure
		switch_to_public_schema
	end

	protected

	def ensure_service_params
		missing_params = ["hub_id", "feed_name", "type_name"].reject do |key|
			params.key?(key) || params[key]
		end
		if missing_params.length > 0
			show_400 "Request is missing required parameters: #{missing_params.join ', '}."
		end
	end

	def service_params
		params.reject { |k, v| ["action", "controller", "organization_id"].include? k }
	end

	def service_not_found_for_id 
		"Service, with id: '#{params[:id]}', was not found"
	end
end