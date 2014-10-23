class Api::V2::FiltersController < Api::V2::BaseController
  # before_filter :authenticate!
  # load_and_authorize_resource

  def index
    @filters = current_brand.filters
    render :index
  end

  def show
    if (@filter = current_brand.filters.where(id: params[:id]).first)
      render :show
    end
  end

  def create
    @filter = Filter.new(only_filter)
    @filter.constraints.build(constraints)

    if @filter.save
      render :show
    else
      render :json => msg_hash(:filter, 'create'), :status => 406
    end
  end

  def update
    if @filter = Filter.find_by_id(params[:id])

      @filter.assign_attributes(only_filter)
      @filter.constraints.destroy_all
      @filter.constraints.build(constraints)

      if @filter.save
        render :show
      else
        render :json => msg_hash(:filter, 'update'), :status => 406
      end
    else
      render :json => msg_hash(:filter, 'update'), :status => 406
    end
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

  def only_filter
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:id, :name, :display_name, :disabled, :position_position, {:tags => []})
  end

  def constraints
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:filter).permit(:constraints => [:feed_name, :type_name]).require(:constraints)
  end

end
