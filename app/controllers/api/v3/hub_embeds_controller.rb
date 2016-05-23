require 'digest/md5'

class Api::V3::HubEmbedsController < Api::V3::ApiController
  include Api::HubScoped

  def index
    authorize! :index, HubEmbed
    all_presets
    render :index
  end

  def show
    authorize! :show, a_preset
    render :show
  end

  def create
    authorize! :create, HubEmbed

    if @embed = HubEmbed.create(hub_preset_params)
      render :show
    else
      render :json => msg_hash(@embed, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, a_preset

    if @embed.update_attributes(hub_preset_params)
      render :show
    else
      render :json => msg_hash(@embed, 'update'), :status => 422
    end
  end

  def destroy
    authorize! :destroy, a_preset
    if @embed.destroy
      render :json => msg_hash(HubEmbed, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(HubEmbed, 'destroy'), :status => 422
    end
  end

  private
  def all_presets
    @embeds = owner_hub.embeds.all
  end

  def a_preset
    @embed = HubEmbed.find(preset_id)
  end

  def hub_preset_params
    params.require(:embed).permit(:name, :hub_id, config: [:live, :theme])
  end

  def preset_id
    params[:preset_id] || params[:id]
  end
end
