class KickstartController < ApplicationController

  def admin
  end

  def frontend
    respond_to do |format|
      format.html { render 'kickstart/frontend' }
      format.any  { head :not_found }
    end
  end

end
