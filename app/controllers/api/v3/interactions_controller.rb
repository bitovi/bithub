class Api::V3::InteractionsController < Api::V3::BaseController

  before_filter :authenticate_account!
  before_action :set_interaction, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    if (@source = interacted_with)
      @data = Interaction.stats(resolution, source_type, source_id).all
    else
      @data = Interaction.stats(resolution).all
    end
      
    render :json => { interactions: @data }
  end

  def create
    @interaction = Interaction.new(interaction_params)
    @interaction.save
    respond_with(@interaction)
  end

  def destroy
    @interaction.destroy
    respond_with(@interaction)
  end

  private

  def interaction_params
    params.require(:interaction).permit(:source_id, :source_type, :created_at)
  end

  def interaction_type
    params.permit(:type)
  end

  def interacted_with
    if source_type
      if source_type == 'embeds' && source_id
        Embed.find(1)
      elsif source_type == 'cards' && source_id
        Entity.find(1)
      end
    else
      fail ArgumentError.new("Missing params.")
    end
  end

  private

  def resolution
    params['resolution'] || 'hour'
  end

  def source_type
    params[:source_type]
  end

  def source_id
    params[:source_id]
  end

  def owner_id
    params[:owner_id]
  end
end
