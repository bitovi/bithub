class Api::CountriesController < ApplicationController
  load_and_authorize_resource
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @countries = Country.all
    render :index
  end

end
