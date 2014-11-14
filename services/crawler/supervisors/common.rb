module Supervisors
  module Common

    def static_config
      Celluloid::Actor[:configurator].static_config
    end

    def name
      (path + ['supervisor']).join('_').to_sym
    end

    def child_name(next_level_name)
      (child_path(next_level_name) + ['supervisor']).join('_').to_sym
    end

    def path
      @current_level
    end

    def child_path(next_level)
      path + [next_level]
    end
  end
end
