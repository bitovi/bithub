class Api::HubsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account
	before_action :sanitize_params
	before_action :ensure_organization_param_exists, only: [ :create ]
	
	def create
		Apartment::Tenant.switch!(session[:tenant_name])
	
		brand = Brand.where(organization_id: params[:organization_id]).first
		hub = brand.embeds.build(hub_params)
		begin
			ActiveRecord::Base.transaction do
				hub.name = hub_params[:name]
				hub.save!
			end
		rescue ActiveRecord::RecordInvalid => e
			return render_error_message e, e, :unprocessable_entity
		end
		render json: hub, status: :created
	ensure
		Apartment::Tenant.switch!
	end
	
	def index
		Apartment::Tenant.switch!(session[:tenant_name])	
		return render json: Embed.all, status: :ok
	ensure
		Apartment::Tenant.switch!
	end
	
	def show
		Apartment::Tenant.switch!(session[:tenant_name])
		return render json: Embed.find(params[:id]), status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Embed, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	ensure
		Apartment::Tenant.switch!
	end
	
	def update
		Apartment::Tenant.switch!(session[:tenant_name])
		hub = Embed.find(params[:id])
		hub.update(params[:hub])
		return render json: hub, status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Embed, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	rescue ActiveRecord::UnknownAttributeError => e
		return render json: {
			message: e.message
		}, status: :bad_request
	ensure
		Apartment::Tenant.switch!
	end
	
	def destroy
		Apartment::Tenant.switch!(session[:tenant_name])
		Embed.find(params[:id]).destroy!
		
		CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)

		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Embed, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	ensure
		Apartment::Tenant.switch!
	end
	
	protected
	
	def ensure_organization_param_exists
		return unless params[:organization_id].blank?
		return render json: { 
			message: "You must provide an organization_id when creating a hub"
		}, status: :bad_request
	end
	
	def hub_params
		{ name: params[:name] || Bazaar.heroku }
	end
	
	def sanitize_params
		sanitize params
	end
end