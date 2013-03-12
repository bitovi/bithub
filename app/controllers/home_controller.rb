class HomeController < ApplicationController

  def latest
    render :json => { foo: 'bar' }
  end

  def greatest
    render :json => { foo: 'baz' }
  end

end
