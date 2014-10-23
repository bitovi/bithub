class FrontendController < ApplicationController

  def index
    @domain = request.domain

    ###
    template = 'frontend/index'

    if request.subdomain.present? && request.subdomain != "www"
      template = 'frontend/index'
    end

    respond_to do |format|
      format.html { render template }
      format.any  { head :not_found }
    end
  end

end
