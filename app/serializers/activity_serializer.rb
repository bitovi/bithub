class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :value, :type

  def type
    object.class.to_s.downcase
  end
end
