class Api::V3::FiltersController < Api::V3::ApiController
  include Api::HubScoped

  def index
    authorize! :index, Filter
    @filters = owner_hub.filters
    render 'api/v3/filters/index'
  end

  def show
    authorize! :show, a_filter
    if @filter
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'show'), :status => 404
    end
  end

  def create
    @filter = owner_hub.filters.build(filter_params)
    @filter.natlang_queries.build(normalized_queries)
    @filter.natlang_queries.map(&:clean)

    if @filter.save
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'create'), :status => 406
    end
  end

  def update
    @filter = owner_hub.filters.find(filter_id)
    queries_params.each do |q|
      if (nlq = @filter.natlang_queries.find(q[:id]))
        nlq.assign_attributes(q)
        nlq.clean
        nlq.save
      else
        @filter.natlang_queries.build(q)
      end
    end

    if @filter.save
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'create'), :status => 406
    end
  end

  def destroy
    hub = current_brand.hubs.find(hub_id)
    @filter = hub.filters.find(filter_id)

    if @filter.destroy
      render :json => msg_hash(@filter, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private
  
  def a_filter
    @filter = Filter.find(filter_id)
  end

  def hub_id
    params[:hub_id] || params[:filter].andand[:hub_id]
  end

  def filter_id
    params[:filter_id] || params[:id]
  end

  def filter_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:id, :action, :hub_id)
  end

  def normalized_queries
    NatlangQueries::Normalizer.new(queries_params).normalized
  end

  def queries_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(natlang_queries: %i(id is_negated attr_name op val)).require(:natlang_queries)
  end
end
