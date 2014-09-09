class KickstartController < ApplicationController

  def admin
  end

  def frontend

    template = 'kickstart/forward'

    @domain = request.domain

    if request.subdomain.present? && request.subdomain != "www"
      template = 'kickstart/frontend'
    end

    respond_to do |format|
      format.html { render template }
      format.any  { head :not_found }
    end
  end

end
