module Traits
  module AmqpDeclaration

    def x(x_name)
      @x ||= RabbitFactory.new($rabbitmq).x(x_name)
    end

    def q(q_name)
      @q ||= RabbitFactory.new($rabbitmq).q(q_name)
    end

  end
end
