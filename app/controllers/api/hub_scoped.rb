module Api::HubScoped
  def owner_hub
    @hub = Hub.find(hub_id)
  end
  
  def hub_id
    params[:hub_id]
  end
end
