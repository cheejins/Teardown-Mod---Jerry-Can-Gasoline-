tool = {
    tool = {

        input = {
            didShoot = function() return tool.tool.active() and InputPressed('lmb') end,
            didReset = function() return tool.tool.active() and InputPressed('r') end,
            igniteAtCrosshair = function() return tool.tool.active() and InputPressed('rmb') end,
            didReleaseDrops = function() return tool.tool.active() and InputPressed('g') end,

            isShooting = function() return tool.tool.active() and InputDown('lmb') end,
        },

        setup = {
            name = 'jerryCan',
            title = 'Jerry Can',
            voxPath = 'MOD/vox/jerryCan.vox',
        },

        active = function()
            return GetString('game.player.tool') == tool.tool.setup.name and (GetPlayerVehicle() == 0)
        end,

        init = function(enabled)
            RegisterTool(tool.tool.setup.name, tool.tool.setup.title, tool.tool.setup.voxPath)
            SetBool('game.tool.'..tool.tool.setup.name..'.enabled', enabled or true)
        end,

    }
}


function tool.run()

    if tool.tool.input.isShooting() then -- Shooting.
        Gun.actions.shoot()
    end

    if tool.tool.input.igniteAtCrosshair() then
        Gun.actions.igniteAtCrosshair()
    end

    if tool.tool.input.didReset() then -- Pressed Reset.
        Gun.actions.reset()
    end

    if tool.tool.input.didReleaseDrops() then
        Gun.actions.releaseDrops()
    end

end


tool.draw = {}

function tool.draw.process()

    if tool.tool.active() then
        tool.draw.drawToolNameOptionsHint()
    end

end

function tool.draw.drawToolNameOptionsHint()

    UiPush()

        UiTranslate(UiCenter(), UiHeight() - (addHeight or 56))

        UiAlign("center middle")
        UiFont("bold.ttf", 24)
        UiTextShadow(0,0,0, 1, 0.3, 0.5)
        UiColor(1,1,1, 1)

        UiText('Press "ctrl + o" for options.')

    UiPop()

end