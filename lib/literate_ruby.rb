module LiterateRuby
  extend ActiveSupport::Concern
  
  def returning(exp)
    yield exp
    exp
  end

end

ActiveRecord::Base.send(:include, LiterateRuby)
