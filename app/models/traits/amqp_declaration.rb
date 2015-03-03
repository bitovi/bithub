module Traits
  module AmqpDeclaration

    def x(x_name)
      @x ||= RabbitFactory.new(ConnectionManager.instance.shared_rabbit).x(x_name)
    end

    def q(q_name)
      @q ||= RabbitFactory.new(ConnectionManager.instance.shared_rabbit).q(q_name)
    end

  end
end
