module LiterateRuby

  def returning(exp)
    yield exp
    exp
  end

end
