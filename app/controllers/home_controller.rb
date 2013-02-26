class HomeController < ApplicationController

  def latest
    render :json => { penis: 'je recentan' }
  end

  def greatest
    render :json => { penis: 'je velik' }
  end

end
