if veritasreborn and veritasreborn.options.disable_envs_change then
    core:module("CoreEnvironmentAreaManager")
    core:import("CoreShapeManager")
    core:import("CoreEnvironmentFeeder")

    function EnvironmentArea:set_environment(environment)
        return
    end
    function EnvironmentAreaManager:environment_at_position(pos)
        return
    end
    function EnvironmentAreaManager:update(t, dt)
        return
    end
end