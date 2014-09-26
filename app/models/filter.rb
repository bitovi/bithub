class Filter < ActiveRecord::Base

  validates_presence_of :is_conj

  has_one :embed_filter, :dependent => :destroy
  has_one :embed, :through => :embed_filter

  has_and_belongs_to_many :queries,
    class_name: "NaturalLanguageQuery",
    foreign_key: "filter_id",
    association_foreign_key: "natural_language_query_id"

  def combined_queries
    QueryCombinator.new(self.queries.all, is_conj).combine
  end

  def all?
    is_con
  end

  def any?
    not(is_conj)
  end

  def covers?(entity)
    check = (constraints.map{|c| c.feed_name}.include?(entity.feed_name)) && (constraints.map {|c| c.type_name}.include?(entity.type_name))

    if !self.tags.blank?
      check = check && !(self.tags & entity.tag_list).empty?
    end

    check
  end
end
