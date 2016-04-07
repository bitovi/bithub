class Api::HubsController < Api::BaseController
	include Api::Helpers::Filter
	
	before_action :ensure_current_account
	before_action :sanitize_params
	before_action :ensure_organization_param_exists, only: [ :create ]
	
	def create
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
	end
	
	def index
		render json: Embed.all, status: :ok
	end
	
	def show
		embed = Embed.find(params[:id])
		
		Brand.switch! Brand.find(embed[:brand_id]).tenant_name
		render json: embed, status: :ok
	rescue ActiveRecord::RecordNotFound
		render json: {
			message: "Embed, with id: '#{params[:id]}' was not found"
		}, status: :not_found
	end
	
	def destroy
		embed = Embed.find(params[:id])
		Brand.switch! Brand.find(embed[:brand_id]).tenant_name
		embed.destroy!
		CleanOrphanedEntitiesJob.perform_later(Apartment::Tenant.current)
		
		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		return render json: {
			message: "Embed, with id: '#{params[:id]}' was not found"
		}, status: :not_found
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