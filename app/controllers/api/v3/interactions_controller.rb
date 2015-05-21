class Api::V3::InteractionsController < Api::V3::BaseController

  before_filter :authenticate_account!

  respond_to :html

  def index
    @zoom = zoom
    @data = Interaction.stats(resolution, zoom, composed_filter).all
    render :index
  end

  def create
    @interaction = Interaction.new(interaction_params)
    @interaction.save
    render json: @interaction
  end

  def destroy
    @interaction.destroy
    render json: @interaction
  end

  private

  def interaction_params
    params.require(:interaction).permit(:primary_source_id, :primary_source_type, :secondary_source_id, :secondary_source_type, :event_type, :event_subtype, :created_at)
  end

  def interaction_type
    params.permit(:type)
  end

  private
  
  def resolution
    params['resolution'] || 'hour'
  end

  def composed_filter
    attrs = %i(primary_source_id secondary_source_id primary_source_type secondary_source_type event_type event_subtype)

    Hash[attrs.select do |a|
      params[a].present?
    end.map do |a|
      [a, params[a]]
    end]
  end

  def zoom
    params[:zoom] || 'detailed'
  end

  def set_zoom
    @zoom = zoom
  end
end
