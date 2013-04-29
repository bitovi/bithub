class Admin::RulesController < Admin::AdminController
  def index
    @rules = Rule.page params[:page]
    render 'index'
  end
  
  def new
    @rule = Rule.new
    render :new
  end

  def edit
    @rule = Rule.find(params[:id])
    render :edit
  end

  def create
    aliases = params[:rule].delete(:required_tags)
    @rule = Rule.new
    @rule.required_tags = aliases.split(',')
    @rule.assign_attributes(params[:rule])

    if @rule.save
      redirect_to admin_rules_path
    else
      render :text => 'jebiga'
    end
  end

  def update
    @rule = Rule.find(params[:id])
    rts = params[:rule].delete(:required_tags)
    @rule.required_tags = rts.split(',')
    @rule.assign_attributes(params[:rule])
    if @rule.save
      redirect_to admin_rules_path
    else
      render :text => 'jebiga'
    end
  end

  def destroy
  end
end
