Gun = {}

Gun.actions = {

    shoot = function()
        TimerRunTimer(timers.gun.shoot, {
            -- Functions to call.
            Gun.actions.createShot,
        }, false)
    end,

    -- Creates a drop projectile.
    createShot = function()
        local toolTr = TransformCopy(GetBodyTransform(GetToolBody()))
        toolTr.pos = TransformToParentPoint(toolTr, Vec(0.7,0.2,-1))

        local spreadMult = math.random(0, regGetFloat('tool.pour.spread'))
        toolTr.rot = QuatRotateQuat(
            toolTr.rot, 
            QuatEuler(
                math.random()*spreadMult,
                math.random()*spreadMult,
                math.random()*spreadMult))

        createProj(toolTr, projectiles, projPresets.jerryCan)

    end,

    igniteAtCrosshair = function()

        local hit, pos = RaycastFromTransform(GetCameraTransform())
        if hit then
            -- Spawn a fire at the position of the drop.
            Gas.drops.burn.burnPosition(pos)

            --- Query closest drop and burn it.
            -- Spawn a burning drop of gas.
            -- Gas.drops.crud.create(GetCameraTransform())
            -- Gas.drops.burn.igniteDrop(Gas.dropsList[#Gas.dropsList])
        end

    end,

    reset = function()
        Gas.dropsList = {}
        projectiles = {}
        dbp('Thy drops hath been reset.' .. sfnTime(), true)
        buzz()
    end,

    releaseDrops = function ()
        for i = 1, #Gas.dropsList do
            local drop = Gas.dropsList[i]
            drop.tr.pos = VecAdd(drop.tr.pos, Vec(0, -0.5, 0))
            drop.sticky.shape = nil
        end
    end

}
