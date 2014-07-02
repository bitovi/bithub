module Solipsism

  def has_an_attribute?(attr)
    reflections.include?(attr.to_sym) ||
    reflections.include?(attr.to_s.pluralize.to_sym) ||
    attribute_names.include?(attr.to_s) ||
    attribute_names.include?(attr.to_s.pluralize)
  end

  def relation_attribute?(attr)
    reflections.include?(attr.to_sym) ||
    reflections.include?(attr.to_s.pluralize.to_sym)
  end

end
