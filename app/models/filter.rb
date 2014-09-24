class Filter < ActiveRecord::Base

  include RankedModel
  ranks :position

  validates_presence_of :name, :is_conjunctive

  has_one :embed_filter, :dependent => :destroy
  has_one :embed, :through => :embed_filter

  has_and_belongs_to_many :queries,
    class_name: "NaturalLanguageQuery",
    foreign_key: "filter_id",
    association_foreign_key: "natural_language_query_id"

  def disabled=(value)
    self.props_will_change!
    self.props['disabled'] = (!!value).to_s
  end

  def disabled
    disabled = self.props['disabled']
    if disabled == true or disabled == 'true'
      return true
    else
      return false
    end
  end

  def covers?(entity)
    check = (constraints.map{|c| c.feed_name}.include?(entity.feed_name)) && (constraints.map {|c| c.type_name}.include?(entity.type_name))

    if !self.tags.blank?
      check = check && !(self.tags & entity.tag_list).empty?
    end

    check
  end

  def all?
    is_conjunctive
  end

  def any?
    not(is_conjunctive)
  end

  def weight
    (constraints.count * 1) + (tags.count * 10)
  end

end
