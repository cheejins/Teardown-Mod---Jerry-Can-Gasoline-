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

    if tool.tool.input.didShoot() then -- Pressed Shoot.
        dbp('SHOOTS GUN :O ', true)
    end

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
