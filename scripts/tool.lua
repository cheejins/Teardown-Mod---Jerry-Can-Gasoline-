function init_tool()
    tool = {
        tool = {

            input = {
                didShoot = function() return tool.tool.active() and InputPressed('lmb') end,
                didReset = function() return tool.tool.active() and InputPressed('r') end,
                igniteAtCrosshair = function() return tool.tool.active() and InputPressed('rmb') end,
                didReleaseDrops = function() return tool.tool.active() and InputPressed('g') end,
                didIgniteAllDrops = function() return tool.tool.active() and InputPressed('mmb') end,

                isShooting = function() return tool.tool.active() and InputDown('lmb') end,
            },

            setup = {
                name = 'gasCan',
                title = 'Gas Can',
                voxPath = 'MOD/vox/gasCan.vox',
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
            Gun_actions_shoot()
        end

        if tool.tool.input.igniteAtCrosshair() then
            Gun_actions_igniteAtCrosshair()
        end

        if tool.tool.input.didReset() then -- Pressed Reset.
            Gun_actions_reset()
        end

        if tool.tool.input.didReleaseDrops() then
            Gun_actions_releaseDrops()
        end

        if tool.tool.input.didIgniteAllDrops() then
            Gun_actions_igniteAllDrops()
        end

    end


    tool.draw = {}

    function tool.draw.process()

        if tool.tool.active() then
            uiDrawToolNameOptionsHint()
        end

    end

    tool.tool.init()

end

