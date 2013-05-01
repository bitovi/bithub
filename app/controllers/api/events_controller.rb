class Api::EventsController < Api::ApiController
  TAG_FIELDS = ['tag', 'feed', 'category']
  DELIMITERS = { :and => ',', :or => '|', :between => ':' }
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    scope = Event.scoped
    scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    scope = scope.limit(muster_query[:limit]) if muster_query[:count].blank?

    scope = apply_regular_params_to_scope(scope, params)
    scope = apply_taggables_to_scope(scope, params)
    scope = calculate_upvotes(scope, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_order_to_scope(scope, muster_query)
      @events = EventDecorator.decorate_collection(scope.all)
      render :index
    end
  end

  def show
    @event = EventDecorator.decorate(Event.find(params[:id]))
    render :show
  end

  def create
    @event = Event.new_from_bithub(params[:event])
    @event.author = current_user
    if @event.save
      render :json => @event, :status => 200
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

  def update
    @event = Event.find(params[:id])
    if Event.update(params[:event])
      render :status => 200
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

  private

  def apply_order_to_scope(scope, muster_query)
    if !muster_query[:order].blank?
      attribute, direction = muster_query[:order].first.split
      attribute = "total_upvotes" if attribute == "upvotes" # total_upvotes => calculated field
      scope = scope.order("#{attribute} #{direction}")
    end
    scope
  end

  def calculate_upvotes(scope, params)
    scope = scope.select_with_upvotes(include_events_in_upvote_calc?(params))
    scope
  end

  # /events/?category=article|plugin|app&order=upvotes:desc&limit=3
  def apply_taggables_to_scope(scope, params)
    taggables = pluck_taggables(params)
    if taggables
      scope = scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
      scope = scope.tagged_with(taggables[:all]) if taggables[:all]
    end
    scope
  end

  # get taggables and put them in a hash, eg. { :any => [...], :all => [...] }
  def pluck_taggables(params)
    hash = Hash.new 
    params.find_all{|el| TAG_FIELDS.include?(el[0])}.each{|el| handle_taggables(hash, el)}
    hash
  end

  # eg. tag=code|article (OR), tag=code,github (AND)
  def handle_taggables(hash, keyval)
    key = keyval[0]; val = keyval[1]
    if val.include? DELIMITERS[:or]
      hash[:any] = val.split(DELIMITERS[:or])
    elsif val.include? DELIMITERS[:and]
      hash[:all] = val.split(DELIMITERS[:and])
    elsif val.kind_of?(Array)
      hash[:all] = val
    else
      hash[:all] = Array.wrap(val)
    end
    hash
  end

  def apply_regular_params_to_scope(scope, params)
    regpar = pluck_regular_params(params)
    scope = scope.where(regpar) if regpar
    scope
  end
  
  def pluck_regular_params(params)
    hash = Hash.new
    params.each do |k,v|
      if Event.has_an_attribute?(k) && !TAG_FIELDS.include?(k)
        if v.include? DELIMITERS[:between]
          hash[k] = handle_between(k,v)
        elsif v.include? DELIMITERS[:or]
          hash[k] = handle_or(k,v)
        else
          hash[k] = v
        end
      end
    end
    return hash
  end

  def handle_between(key, val)
    lower_str, higher_str = val.split(DELIMITERS[:between])
    type = Event.columns_hash[key].type
    if type == :datetime || type == :date
      if !lower_str || lower_str.blank?
        lower = Date.new(0) + 1.year # Good enough minimum
      else
        lower = DateTime.parse(lower_str)
      end
      if !higher_str || higher_str.blank?
        higher = DateTime.tomorrow # Good enough maximum
      else
        higher = DateTime.parse(higher_str)
      end
    elsif type == :integer
      lower = lower_str && !lower_str.blank? ? lower_str.to_i : -(2**(0.size * 8 -2)) # Platform MIN_INT
      higher = higher_str ? higher_str.to_i : (2**(0.size * 8 -2) -1) # Platform MAX_INT
    else
      klass = Object.const_get(type.capitalize)
      lower = klass.new(lower_str)
      higher = klass.new(higher_str)
    end
    lower..higher
  end

  def include_events_in_upvote_calc?(params)
    taggables = pluck_taggables(params)
    taggables && !taggables[:any]
  end
  
  def handle_or(key, val)
    val.split(DELIMITERS[:or])
  end

end
