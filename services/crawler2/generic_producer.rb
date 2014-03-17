class GenericProducer
  include Celluloid

  def initialize
    continuously_publish
  end

  def continuously_publish
    every(1) do
      kita
    end
  end

  def kita
    Actor[:Publisher].publish "KITA"
  end
end
