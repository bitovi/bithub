class Admin::CountriesController < Admin::AdminController

  def index
    @countries = Country.page params[:page]
    render 'index'
  end
  
  def new
    @countries = Country.new
    render :new
  end

  def edit
    @country = Country.find(params[:id])
    render :edit
  end

  def create
    @country = Country.new(params[:country])

    if @country.save
      redirect_to admin_countries_path
    else
      render :json => { error: @country.errors.messages }, status: 406
    end
  end

  def update
    @country = Country.find(params[:id])
    if @country.update_attribute(params[:country])
      redirect_to admin_countries_path
    else
      render :json => { error: @country.errors.messages }, status: 406
    end
  end

end
