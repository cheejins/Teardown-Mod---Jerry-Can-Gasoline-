Gun = {}

Gun_actions_shoot = function()

    if not UI_GAME then
        TimerRunTimer(timers.gun.shoot, {
            -- Functions to call.
            Gun_actions_createShot,
        }, false)
    end

    -- sounds.play.pour(GetCameraTransform().pos, 2)

end

-- Creates a drop projectile.
Gun_actions_createShot = function()
    local toolTr = TransformCopy(GetBodyTransform(GetToolBody()))
    toolTr.pos = TransformToParentPoint(toolTr, Vec(0.7,0.2,-1))

    local spreadMult = (math.random() - 0.5) * regGetFloat('tool.pour.spread')
    toolTr.rot = QuatRotateQuat(
        toolTr.rot,
        QuatEuler(
            math.random()*spreadMult,
            math.random()*spreadMult,
            math.random()*spreadMult))

    createProj(toolTr, projectiles, projPresets.gasCan)

    -- if rdm() < 0.2 / regGetFloat('tool.pour.rate') then
    --     local pos = GetCameraTransform().pos
    --     sounds.play.drop(pos, 2)
    -- end

end

Gun_actions_igniteAtCrosshair = function()

    local hit, pos = RaycastFromTransform(GetCameraTransform())
    if hit then

        -- Spawn a fire at the position of the drop.
        SpawnFire(pos)

        for i = 1, 5 do
            local vecArea = Vec(math.random()-0.5, math.random()-0.5, math.random()-0.5)
            SpawnFire(VecAdd(pos, vecArea))
        end

        for i = 1, 4 do
            Gas_drops_effects_renderDropBurning(pos)
        end

    end

end

Gun_actions_reset = function()
    Gas.dropsList = {}
    projectiles = {}

    local gasDropBodies = FindBodies('gasDrop', true)
    for key, gasDropBody in pairs(gasDropBodies) do
        Delete(gasDropBody) -- Remove all gas drop bodies.
    end

    dbp('Thy drops hath been reset.' .. sfnTime(), true)
    beep()
end

Gun_actions_releaseDrops = function ()
    for i = 1, #Gas.dropsList do
        local drop = Gas.dropsList[i]
        drop.tr.pos = VecAdd(drop.tr.pos, Vec(0, -0.5, 0))
        drop.sticky.shape = nil
    end
end

function Gun_actions_igniteAllDrops()
    for index, drop in ipairs(Gas.dropsList) do
        Gas_drops_burn_igniteDrop(drop)
    end
end

