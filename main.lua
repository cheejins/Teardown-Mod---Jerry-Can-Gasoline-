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


function init()

    CONFIG = {
        soundEnabled = true,
        slowMotion = false,
    }

    UI_GAME = false
    checkRegInitialized()

    initSounds()
    initDebug()
    initTimers()
    init_tool()

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


function handleCommand(cmd) HandleQuickload(cmd) end
function HandleQuickload(cmd)
    for _, word in ipairs(splitString(cmd, " ")) do
        if word == "quickload" then
            init()
        end
        break
    end
end

function splitString(str, delimiter)
    local result = {}
    for word in string.gmatch(str, '([^'..delimiter..']+)') do
        result[#result+1] = trim(word)
    end
    return result
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
 end