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

    -- DEBUG
    debugMod()

    runTimers()

    manageActiveProjs(projectiles)

    tool.run()
    Gas.run()

end


-- every frame check next node of gasoline. control rate of spread this way.
-- grouped gasoline will make a web and explode quicker while lines of gasoline will be sequential and a bit slower.



-- Gas visual type
    -- option to choose between spray can and sprites
-- Check body mass change to readjust sticky gas points



UpdateQuickloadPatch()