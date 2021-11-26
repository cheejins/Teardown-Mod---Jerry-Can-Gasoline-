#include "scripts/debug.lua"
#include "scripts/gas.lua"
#include "scripts/gun.lua"
#include "scripts/projectiles.lua"
#include "scripts/registry.lua"
#include "scripts/timers.lua"
#include "scripts/sound.lua"
#include "scripts/tool.lua"
#include "scripts/umf.lua"
#include "scripts/ui.lua"
#include "scripts/utility.lua"

------------------------------------------------
--- Jerry Can (Gasoline)
--- By: Cheejins
------------------------------------------------

CONFIG = {
    soundEnabled = true,
    slowMotion = false,
    -- slowMotion = true,
}


function init()
    tool.tool.init()
    initTimers()
    UI_GAME = false
end


function tick()

    runTimers()
    manageActiveProjs(projectiles)

    tool.run()
    Gas.run()

    if InputPressed('p') then
        modReset()
        buzz()
    end

    debugMod()

end

function draw()

    if tool.tool.active() then
        uiDrawToolNameOptionsHint()
    end
    uiManageGameOptions()

end



UpdateQuickloadPatch()