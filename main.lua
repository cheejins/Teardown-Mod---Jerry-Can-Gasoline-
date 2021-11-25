#include "scripts/debug.lua"
#include "scripts/gas.lua"
#include "scripts/gun.lua"
#include "scripts/projectiles.lua"
#include "scripts/timers.lua"
#include "scripts/sound.lua"
#include "scripts/tool.lua"
#include "scripts/umf.lua"
#include "scripts/utility.lua"

------------------------------------------------
--- This script manages the entire mod (woah).
------------------------------------------------

CONFIG = {
    soundEnabled = true,
    slowMotion = false,
    -- slowMotion = true,
}


REG = {
    -- gas
        -- pour
            -- rate
            -- spread
        -- fire
            -- spread
                -- rate
                -- efficiency
}


function init()
    tool.tool.init()
end


function tick()

    runTimers()
    manageActiveProjs(projectiles)

    tool.run()
    Gas.run()


    debugMod()

end

function draw()

    tool.draw.process()

end


UpdateQuickloadPatch()