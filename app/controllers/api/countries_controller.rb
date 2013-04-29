class Api::CountriesController < ApplicationController
  respond_to :json
  rescue_from ActiveRecord::RecordInvalid, :with => :show_errors
  rescue_from ActiveRecord::RecordNotFound, :with => :show_errors

  def index
    @countries = Country.all

    render :index
  end

end
