module LiterateRuby

  def returning(exp)
    yield
    exp
  end
    
end
