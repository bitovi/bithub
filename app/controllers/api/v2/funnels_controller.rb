class Api::V2::FunnelsController < Api::V2::BaseController
  respond_to :json

  def index
    @funnel_groups = FunnelGroup.all
    render :index
  end

  def show
    @funnel_group = FunnelGroup.find_by_id(params[:id])
    render :show
  end

  def create
    constraints = params[:funnel].delete(:constraints)
    if @funnel_group = FunnelGroup.create(params[:funnel]) && @funnel_group.assoc_funnels(constraints)
      render :show
    else
      render :json => msg_hash(@funnel_group, 'destroy'), :status => 406
    end
  end

  def update
    constraints = params[:funnel].delete(:constraints)
    @funnel_group = FunnelGroup.find_by_id params[:id]

    if @funnel_group.update_attributes(params[:funnel]) && @funnel_group.assoc_funnels(constraints)
      render :show
    else
      render :json => msg_hash(@funnel_group, 'destroy'), :status => 406
    end
  end

  private
  def only_funnel_group
    params.require(:funnel).permit!
  end

end
