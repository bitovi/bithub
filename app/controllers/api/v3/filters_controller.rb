class Api::V3::FiltersController < Api::V3::BaseController
  before_filter :authenticate!
  # load_and_authorize_resource

  def index
    embed = current_brand.embeds.find(params[:embed_id])
    @filters = embed.filters
    render :index
  end

  def show
    embed = current_brand.embeds.find(params[:embed_id])
    @filter = embed.filters.find(params[:id])
    if @filter
      render :show
    end
  end

  def create
    embed = current_brand.embeds.find(params[:embed_id])

    @filter = embed.filters.build(params_filter)
    @filter.natlang_queries.build(params_queries)

    if @filter.save
      render :show
    else
      render :json => msg_hash(:filter, 'create'), :status => 406
    end
  end

  def update
  end

  def destroy
    @filter = Filter.find_by_id params[:id]

    if @filter && @filter.destroy
      render :json => msg_hash(@filter, 'destroy', 'success')
    else
      render :json => msg_hash(@filter, 'destroy'), :status => 406
    end
  end

  private

  def params_filter
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:id, :is_conj, :classification)
  end

  def params_queries
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(natlang_queries: %i(is_negated attr op val)).require(:natlang_queries)
  end
end
