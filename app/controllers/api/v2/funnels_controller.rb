class Api::V2::FunnelsController < Api::V2::BaseController
  # before_filter :authenticate!
  # load_and_authorize_resource

  def index
    @funnels = Funnel.all
    render :index
  end

  def show
    if (@funnel = Funnel.find_by_id(params[:id]))
      render :show
    end
  end

  def create
    @funnel = Funnel.new(only_funnel)
    @funnel.constraints.build(constraints)

    if @funnel.save
      render :show
    else
      render :json => msg_hash(:funnel, 'create'), :status => 406
    end
  end

  def update
    if @funnel = Funnel.find_by_id(params[:id])

      @funnel.assign_attributes(only_funnel)
      @funnel.constraints.destroy_all
      @funnel.constraints.build(constraints)

      if @funnel.save
        render :show
      else
        render :json => msg_hash(:funnel, 'update'), :status => 406
      end
    else
      render :json => msg_hash(:funnel, 'update'), :status => 406
    end
  end

  def destroy
    @funnel = Funnel.find_by_id params[:id]

    if @funnel && @funnel.destroy
      render :json => msg_hash(@funnel, 'destroy', 'success')
    else
      render :json => msg_hash(@funnel, 'destroy'), :status => 406
    end
  end

  private

  def only_funnel
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:funnel).permit(:id, :name, :display_name, {:tags => []})
  end

  def constraints
    @json ||= ActionController::Parameters.new(JSON.parse_nil(request.body.read))
    @json.require(:funnel).permit(:constraints => [:feed_name, :type_name]).require(:constraints)
  end

end
