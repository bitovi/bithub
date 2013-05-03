class Admin::EventsController < Admin::AdminController

  def index
    @events = Event.page params[:page]
    render 'index'
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
  end
end
