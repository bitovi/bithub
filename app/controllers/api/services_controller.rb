class Api::ServicesController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter

	before_action :ensure_current_user
	before_action :sanitize_params
	before_action :ensure_service_params, only: [ :create ]
	before_action :switch_tenant

	def create
		service = Service.new(params).save!
		return render json: service, status: :created
	rescue => e
		show_400 e
	ensure
		switch_to_public_schema
	end

	def index
	
	ensure
		switch_to_public_schema
	end

	def update
	
	ensure
		switch_to_public_schema	
	end

	def destroy
	
	ensure
		switch_to_public_schema
	end

	protected

	def ensure_service_params
		missing_params = ["hub_id", "feed_name", "type_name"].reject do |key|
			params.key?(key) && params[key]
		end
		if missing_params
			show_400 "Request is missing required parameters."
		end
	end
end