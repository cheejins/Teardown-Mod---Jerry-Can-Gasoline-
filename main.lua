#include "scripts/debug.lua"
#include "scripts/gas.lua"
#include "scripts/gun.lua"
#include "scripts/kdTree.lua"
#include "scripts/projectiles.lua"
#include "scripts/registry.lua"
#include "scripts/sound.lua"
#include "scripts/timers.lua"
#include "scripts/tool.lua"
#include "scripts/ui.lua"
#include "scripts/umf.lua"
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
    initDebug()
    initTimers()
    tool.tool.init()

end

function tick()

    runTimers()
    manageProjectiles()

    tool.run()
    Gas_run()

    debugMod()

end

function draw()

    -- Render drop particles.
    if not regGetBool('tool.gas.renderGasParticles') then
        Gas_drops_effects_renderDropsIdleSimple()
    end

    if tool.tool.active() then
        uiDrawToolNameOptionsHint()
    end

    -- Ui options screen.
    uiManageGameOptions()

end

UpdateQuickloadPatch()