class Api::HubsController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter
	
	before_action 	:ensure_current_user
	before_action 	:sanitize_params
	before_action 	:ensure_organization_param_exists
	before_action	:ensure_organization_member, only: [ :create ]
	before_action 	:switch_tenant
	
	def create
		brand = Brand.where(organization_id: params[:organization_id]).first
		hub = brand.hubs.build(hub_params)
		begin
			ActiveRecord::Base.transaction { hub.save! }
		rescue ActiveRecord::RecordInvalid => e
			show_422 e
		end
		render json: hub, status: :created
	ensure
		switch_to_public_schema
	end
	
	def index	
		return render json: { data: filter(Hub, params) }, status: :ok
	ensure
		switch_to_public_schema
	end
	
	def show
		return render json: { data: Hub.find(params[:id]) }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 hub_not_found_for_id
	ensure
		switch_to_public_schema
	end
	
	def update
		hub = Hub.find(params[:id])
		hub.update!(params[:hub])
		return render json: hub, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 hub_not_found_for_id
	rescue ActiveRecord::UnknownAttributeError => e
		show_400 e
	ensure
		switch_to_public_schema
	end
	
	def destroy
		Hub.find(params[:id]).destroy!
		CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)

		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 hub_not_found_for_id
	ensure
		switch_to_public_schema
	end
	
	protected
	
	def hub_params
		{ 
			name: params.fetch(:name, Bazaar.heroku),
			approved_by_default: params.fetch(:approved_by_default, false)
		}
	end

	def hub_not_found_for_id 
		"Hub, with id: '#{params[:id]}', was not found"
	end
end