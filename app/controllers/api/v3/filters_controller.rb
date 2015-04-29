class Api::V3::FiltersController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!

  def index
    authorize! :index, Filter
    @filters = owner_embed.filters
    render 'api/v3/filters/index'
  end

  def show
    authorize! :show, Filter
    if @filter = owner_embed.filters.find(filter_id)
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'show'), :status => 404
    end
  end

  def create
    @filter = owner_embed.filters.build(filter_params)
    @filter.natlang_queries.build(queries_params)

    if @filter.save
      render 'api/v3/filters/show'
    else
      render :json => msg_hash(@filter, 'create'), :status => 406
    end
  end

  def update
    @filter = owner_embed.filters.find(filter_id)
    queries_params.each do |q|
      if (nlq = @filter.natlang_queries.find(q[:id]))
        nlq.update_attributes(q)
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
    embed = current_brand.embeds.find(embed_id)
    @filter = embed.filters.find(filter_id)

    if @filter.destroy
      render :json => msg_hash(@filter, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private

  def embed_id
    params[:embed_id] || params[:filter].andand[:embed_id]
  end

  def filter_id
    params[:filter_id] || params[:id]
  end

  def filter_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:id, :action, :embed_id)
  end

  def queries_params
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(natlang_queries: %i(id is_negated attr_name op val)).require(:natlang_queries)
  end
end
