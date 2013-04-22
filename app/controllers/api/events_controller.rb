class Api::EventsController < ApplicationController
  TAG_FIELDS = ['tag', 'feed', 'category']
  DELIMITERS = { :and => ',', :or => '|', :between => ':' }
  respond_to :json
  before_filter :authenticate_user!, :only => ['create', 'update']

  def index
    muster_query = request.env['muster.query']
    Rails.logger.info muster_query

    scope = Event.scoped
    # scope = scope.joins(muster_query[:joins]) if !muster_query[:joins].blank?
    # scope = scope.includes(muster_query[:includes]) if !muster_query[:includes].blank?
    scope = scope.offset(muster_query[:offset]) if !muster_query[:offset].blank?
    scope = scope.limit(muster_query[:limit]) if muster_query[:count].blank?

    Rails.logger.info "TAGGABLES : #{pluck_taggables(params)}"
    Rails.logger.info "ALL OTHERS : #{translate_params(params)}"

    scope = scope.where(translate_params(params))

    taggables = pluck_taggables(params)
    scope = scopefiy_taggables(scope, taggables) if !taggables.empty?

    scope = scope.select_with_upvotes(!taggables[:any])

    if !muster_query[:count].blank?
      render :json => {:count => scope.count(muster_query[:count]) }
    else
      if !muster_query[:order].blank?
        attribute, direction = pluck_order(muster_query[:order])
        attribute = "total_upvotes" if attribute == "upvotes"
        scope = scope.order("#{attribute} #{direction}")
      end
      @events = EventDecorator.decorate_collection(scope.all)
      render :index
    end
  end

  def show
    @event = EventDecorator.decorate(Event.find(params[:id]))
    render :show
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      render :status => 200
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

  # /events/?category=article|plugin|app&order=upvotes:desc&limit=3
  def scopefiy_taggables(scope, taggables)
    scope = scope.tagged_with(taggables[:any], :any => true) if taggables[:any]
    scope = scope.tagged_with(taggables[:all]) if taggables[:all]
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
  
  def translate_params(params)
    h = Hash.new
    params.each do |k,v|
      if Event.has_an_attribute?(k) && !TAG_FIELDS.include?(k)
        if v.include? DELIMITERS[:between]
          h[k] = handle_between(k,v)
        elsif v.include? DELIMITERS[:or]
          h[k] = handle_or(k,v)
        else
          h[k] = v
        end
      end
    end
    return h
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
      lower = lower_str.to_i
      higher = higher_str.to_i
    else
      klass = Object.const_get(type.capitalize)
      lower = klass.new(lower_str)
      higher = klass.new(higher_str)
    end
    lower..higher
  end
  
  def handle_or(key, val)
    val.split(DELIMITERS[:or])
  end

  # Only looks for the first order field (no multiple ordering)
  def pluck_order(order_field)
    order_field.first.split
  end
end
