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
--- Gas Can
--- By: Cheejins
------------------------------------------------

CONFIG = {
    soundEnabled = true,
    slowMotion = false,
}

function init()

    UI_GAME = false
    checkRegInitialized()

    initSounds()

    tool.tool.init()
    initTimers()
    initProjectiles()



end


function tick()

    runTimers()
    manageActiveProjs(projectiles)

    tool.run()
    Gas.run()

    debugMod()

end

function draw()

    if tool.tool.active() then
        uiDrawToolNameOptionsHint()
    end

    uiManageGameOptions()

end


UpdateQuickloadPatch()
