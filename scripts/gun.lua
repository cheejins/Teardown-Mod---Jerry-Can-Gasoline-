Gun = {}

Gun.actions = {

    shoot = function()

        if not UI_GAME then
            TimerRunTimer(timers.gun.shoot, {
                -- Functions to call.
                Gun.actions.createShot,
            }, false)
        end

        -- sounds.play.pour(GetCameraTransform().pos, 2)

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

        createProj(toolTr, projectiles, projPresets.gasCan)

        if rdm() < 0.2 / regGetFloat('tool.pour.rate') then
            local pos = GetCameraTransform().pos
            sounds.play.drop(pos, 2)
        end

    end,

    igniteAtCrosshair = function()

        local hit, pos = RaycastFromTransform(GetCameraTransform())
        if hit then
            -- Spawn a fire at the position of the drop.
            Gas.drops.burn.burnPosition(pos)

            for i = 1, 5 do
                Gas.drops.burn.burnPosition(VecAdd(pos, VecScale(rdmVec(), 0.1)))
            end

            for i = 1, 10 do
                Gas.drops.effects.renderDropBurning(pos)
            end

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
