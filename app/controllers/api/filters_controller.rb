class Api::FiltersController < Api::BaseController
	include Api::Helpers::Common
	include Api::Helpers::Filter

	before_action :ensure_current_user
	before_action :sanitize_params
	before_action :ensure_organization_param_exists
	before_action :ensure_organization_member, only: [ :create ]
	before_action :ensure_filters_params, only: [ :create ]
	before_action :switch_tenant

	def create
		filter = Filter.create(filter_params)
		filter.natlang_queries.build([])
		filter.natlang_queries.map(&:clean)
		filter.save!
		return render json: filter, status: :created
	rescue => e
		show_400 e
	end

	def index
		return render json: { data: filter(Filter, params) }, status: :ok
	ensure
		switch_to_public_schema
	end
	
	def show
		return render json: Filter.find(params[:id]), status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 filter_not_found_for_id
	ensure
		switch_to_public_schema
	end

	def update
		filter = Filter.find(params[:id])
		normalized_queries.each do |q|
			if query = filter.natlang_queries.find(q[:id])
				query.assign_attributes(q)
				query.clean
				query.save
			else
				filter.natlang_queries.build(q)
			end
		end

		filter.save!
		return render json: filter, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 filter_not_found_for_id
	rescue ActiveRecord::UnknownAttributeError => e
		show_400 e
	end
	
	def destroy
		HubEmbed.find(params[:id]).destroy!
		return render json: { }, status: :ok
	rescue ActiveRecord::RecordNotFound
		show_404 filter_not_found_for_id
	ensure
		switch_to_public_schema
	end

	protected

	def ensure_filters_params
		missing_params = ["hub_id"].reject do |key|
			params.key?(key) || params[key]
		end
		if missing_params.length > 0
			show_400 "Request is missing required parameters: #{missing_params.join ', '}."
		end
	end

	def filter_params
		params["action"] = params["moderate"]
		params.reject {|k, v| ["moderate", "controller", "organization_id", "natlang_queries"].include? k}
	end

	def filter_not_found_for_id 
		"Filter, with id: '#{params[:id]}', was not found"
	end

	def normalized_queries
		NatlangQueries::Normalizer.new(filter_params).normalized
	end
end