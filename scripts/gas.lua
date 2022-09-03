Gas = {}
Gas.drops = {} -- Holds common data for all drops.
Gas.dropsList = {}
Gas.explodedVehicles = {}
Gas.vehiclesToExplode = {}

GAS_ID = 0

function Gas_run()


    -- Render drop projectiles.
    for i = 1, #projectiles do
        local proj = projectiles[i]
        DrawDot(proj.transform.pos, 0.2,0.2, 0.7,0.9,0, 1) -- Drop projectile
    end


    --> Process drops.
    for i = 1, #Gas.dropsList do
        local drop = Gas.dropsList[i]

        -- Main stuff.
        Gas_drops_physics_process(drop)
        Gas_drops_burn_process(drop)
        Gas_drops_effects_process(drop)

        if not IsHandleValid(drop.body) then
            Gas_drops_crud_markDropForRemoval(drop)
        end

    end

    --> Safely delete specified drops.
    Gas_drops_crud_removeMarkedDrops()

end





Gas.drops.crud = {}

--- Create a drop object and store it in the list of drops.
function Gas_drops_crud_create(tr)


    -- Spawn drop body
    local dropBody = nil
    local spawnEntities = Spawn('MOD/prefab/gasDrop.xml', tr)
    for key, e in pairs(spawnEntities) do
        if GetEntityType(e) == "body" then

            dropBody = e

            local dropShapes = GetBodyShapes(e)
            for key, s in pairs(dropShapes) do
                SetShapeCollisionFilter(s, 64, 64)
            end

        end
    end

    GAS_ID = GAS_ID +1
    local drop = {

        id = GAS_ID,
        removeDrop = false, -- true = mark drop for removal/deletion.

        tr = tr,
        body = dropBody,
        rad = 0.2,

        sticky = {
            shape = nil,
            shapeMass = nil,
            shapeRelativePos = nil,
            explodedStickyVehicle = nil, -- Explode a vehicle only once (drops spread to new vehicles sometimes, prevents nuke explosions.)
            -- stickyVehicleSet = false, -- Set and start timer until explosion.
        },

        color = Vec(1,1,1), -- color
        alpha = 1,

        burn = {
            rad = 0.2, -- The radius the drop spawns fire.
            ignitionValid = false, -- Whether a drop is near fire. True = countdown then start burning.
            isBurning = false,
            ignitionDistance = regGetFloat('tool.gas.ignitionDistance'),
        },

        timers = {
            preBurn =   {time = 0, rpm = 60 / regGetFloat('tool.gas.preburnTime')}, -- Once drop is near fire, wait before igniting the drop.
            burn =      {time = 0, rpm = 60 / regGetFloat('tool.gas.burnTime')}, -- Burns regardless of material type.
            -- vehicleExplosion = {time = 0, rpm = 60 / regGetFloat('tool.gas.explosiveVehiclesDelay')}
        }

    }

    -- Registry live updates.
    drop.burn.ignitionDistance = regGetFloat('tool.gas.ignitionDistance')

    -- Drop timer varience.
    drop.timers.burn.rpm = 60 / regGetFloat('tool.gas.burnTime') * 1 + (-0.5 + rdm()) -- Registry live updates.
    drop.timers.preBurn.rpm = 60 / regGetFloat('tool.gas.preburnTime') * 1 + (-0.5 + rdm()) -- Registry live updates.

    -- Drop ignition distance varience.
    drop.burn.ignitionDistance = drop.burn.ignitionDistance * 1 + (-0.5 + rdm())

    -- Initialize time remaining.
    TimerResetTime(drop.timers.preBurn)
    TimerResetTime(drop.timers.burn)

    table.insert(Gas.dropsList, drop)
    dbp('Created drop. ' .. sfnTime())

end

--- Spawn a drop into the world.
function Gas_drops_crud_spawn(pos)

    Gas_drops_crud_create(Transform(pos, QuatEuler(0,0,0)))

    if rdm() < 0.1 / regGetFloat('tool.pour.rate') and regGetBool('tool.soundOn') then
        sounds.play.drop(pos, 2)
    end

    SpawnParticle("smoke", pos, Vec(0,0,0), 0.5, 0.5, 0.5, 0.5)

end

--- Update drop values each frame.
function Gas_drops_crud_updateDrop(drop)
    drop.alpha = drop.timers.burn.time / drop.timers.burn.rpm
end

--- Mark a drop for removal to safely remove it near the end of the frame.
function Gas_drops_crud_markDropForRemoval(drop)
    drop.removeDrop = true
    dbp('Drop marked for removal: ' .. drop.id .. ' ' ..sfnTime())
end

--- Safely delete all drops that are marked for removal.
function Gas_drops_crud_removeMarkedDrops()

    local removeIndecies = {}
    if #Gas.dropsList >= 1 then
        for i = 1, #Gas.dropsList do
            if Gas.dropsList[i].removeDrop then
                table.insert(removeIndecies, i)
            end
        end
    end

    for i = 1, #removeIndecies do
        local drop = Gas.dropsList[removeIndecies[i]]
        Paint(drop.tr.pos, drop.burn.rad*2, "explosion")
        Delete(drop.body)
        table.remove(Gas.dropsList, removeIndecies[i])
    end

end





Gas.drops.physics = {}

---Process the physics of a single drop.
function Gas_drops_physics_process(drop)

    if drop.sticky.shape == nil then -- Right after gas projectile hits something.

        Gas_drops_physics_sticky_dripAndStick(drop) -- Let the drop drip and find a new shape

    elseif Gas_drops_physics_sticky_didMassDecrease(drop) then -- Drop shape broke previous frame.

        Gas_drops_physics_sticky_dripAndStick(drop) -- QCP right after shape breaks.

    else -- Drop is stuck to a shape and did not break last frame.

        -- Place drop pos relative to shape sticky point.
        drop.tr.pos = TransformToParentPoint(GetShapeWorldTransform(drop.sticky.shape), drop.sticky.shapeRelativePos)

    end

    -- Adhere drop body to drop pos
    local dropBodyTr = GetBodyTransform(drop.body)
    local addVec = TransformToLocalPoint(dropBodyTr, AabbGetBodyCenterPos(drop.body))
    addVec = VecScale(addVec, -1)
    local dropBodyPosNew = VecAdd(drop.tr.pos, addVec)
    local dropBodyTrNew = Transform(dropBodyPosNew, drop.tr.rot)
    SetBodyTransform(drop.body, dropBodyTrNew)
    SetBodyAngularVelocity(drop.body, Vec())

    -- Drop removal.
    drop.sticky.shapeMass = GetBodyMass(GetShapeBody(drop.sticky.shape))

    -- Debug.
    dbw('GAS drop '.. drop.id ..' attached body mass ' .. drop.id, drop.sticky.shapeMass)

end

function Gas_drops_physics_processVehicleExplosions(drop, explosionSize)

    if regGetBool('tool.gas.explosiveVehicles') then

        -- Vehicle the drop is sticking to.
        local vehicle = GetBodyVehicle(GetShapeBody(drop.sticky.shape))

        if vehicle ~= 0 then -- Check if vehicle if it is valid.

            -- Check if vehicle has already been exploded by gas.
            local explodedVehicle = false
            for i = 1, #Gas.explodedVehicles do
                if Gas.explodedVehicles[i] == vehicle then
                    explodedVehicle = true
                end
            end

            -- Explode vehicle.
            if explodedVehicle == false then
                local pos = AabbGetBodyCenterPos(GetVehicleBody(vehicle))
                Explosion(pos, explosionSize or 2)
                table.insert(Gas.explodedVehicles, vehicle)
            end

        end

    end

end

function Gas_drops_physics_queryRejectAllDrops()

    for key, drop in pairs(Gas.dropsList) do
        QueryRejectBody(drop.body)
    end

end





Gas.drops.physics.sticky = {}

function Gas_drops_physics_sticky_setShape(drop, shape)

    drop.sticky.shape = shape
    drop.sticky.shapeMass = GetBodyMass(GetShapeBody(shape))
    drop.sticky.shapeRelativePos = TransformToLocalPoint(GetShapeWorldTransform(shape), drop.tr.pos)

    dbp('drop shape set ' .. sfnTime())
end

function Gas_drops_physics_sticky_resetShape(drop)
    drop.sticky.shape = nil -- Set no shape
    drop.sticky.shapeMass = nil
    dbp('drop shape reset ' .. sfnTime())
end

function Gas_drops_physics_sticky_didMassDecrease(drop)
    local massDecreased = drop.sticky.shapeMass > GetBodyMass(GetShapeBody(drop.sticky.shape))
    local shapeDestroyed = drop.sticky.shapeMass == nil
    if massDecreased or shapeDestroyed then
        Gas_drops_physics_sticky_resetShape(drop)
        return true
    end
    return false
end

---Check the surroundings of a drop and attach it to very close objects.
function Gas_drops_physics_sticky_dripAndStick(drop)

    --> Check if drop is touching anything.
    Gas_drops_physics_queryRejectAllDrops()
    local dropRcHit, point, normal, dropRcShape = QueryClosestPoint(drop.tr.pos, 0.3)
    if dropRcHit then

        -- Set shape.
        Gas_drops_physics_sticky_setShape(drop, dropRcShape)
        drop.color = Vec(0,1,0)

    else --> No hit.

        -- Drip down.
        drop.tr.pos = VecAdd(drop.tr.pos, Vec(0, -0.5, 0))

        -- No shape.
        Gas_drops_physics_sticky_resetShape(drop)

        drop.color = Vec(1,0,0)

    end

end






Gas_drops_burn = {}

--- Processes the burning of a drop.
function Gas_drops_burn_process(drop)

    Gas_drops_burn_preBurn(drop)
    Gas_drops_burn_burn(drop)

end

--- Burns a position and applies visual effects. Does not ignite drops.
function Gas_drops_burn_burnPosition(pos)

    for i = 1, 10 do
        local vecArea = VecScale(Vec(math.random()-0.5, math.random()-0.5, math.random()-0.5), regGetFloat('tool.gas.burnThickness'))
        SpawnFire(VecAdd(pos, vecArea))
    end

    SpawnFire(pos)
end

-- Burn after preBurn timer.
function Gas_drops_burn_burn(drop)

    if drop.burn.isBurning then

        if drop.timers.burn.time > 0 then

            for i = 1, 4 do
                if IsHandleValid(drop.body) then
                    Gas_drops_burn_burnPosition(AabbGetBodyCenterPos(drop.body))
                end
            end

            TimerRunTime(drop.timers.burn) -- Consume the drop burn timer.

        elseif drop.timers.burn.time <= 0 then

            Gas_drops_physics_processVehicleExplosions(drop, 2)
            Gas_drops_crud_markDropForRemoval(drop) -- Delete drop.

            if rdm() < 0.75 then
                local rdmPos = Vec(
                    (rdm() - 0.5)/2,
                    (rdm() - 0.5)/2,
                    (rdm() - 0.5)/2)
                MakeHole((VecAdd(drop.tr.pos, rdmPos)), 0.1, 0.1, 0.1, 0.1)
            end

        end

    end
end

-- preBurn before burning.
function Gas_drops_burn_preBurn(drop)


    local fireIsClose = QueryClosestFire(drop.tr.pos, drop.burn.ignitionDistance)
    if fireIsClose then
        drop.burn.ignitionValid = true
    end


    if drop.burn.ignitionValid then -- Drop is near fire but the drop hasn't ignited yet.

        TimerRunTime(drop.timers.preBurn)

        if drop.timers.preBurn.time <= 0 then
            drop.burn.isBurning = true
            drop.burn.ignitionValid = false
        end

    end

end

function Gas_drops_burn_igniteDrop(drop)
    drop.burn.isBurning = true
end




Gas.drops.effects = {}

function Gas_drops_effects_process(drop)

    if regGetBool('tool.gas.renderGasParticles') then
        Gas_drops_effects_renderDropIdle(drop.tr.pos) -- Idle drop
    end

    if drop.burn.isBurning then
        Gas_drops_effects_renderDropBurning(drop.tr.pos) -- Burning drop
    end

end

--- Draw ui dots instead of particles based on.
function Gas_drops_effects_renderDropsIdleSimple()

    do UiPush()

        local camTr = GetCameraTransform()

        for i = 1, #Gas.dropsList do

            local drop = Gas.dropsList[i]
            local dist = VecDist(camTr.pos, drop.tr.pos)
            local s = (90/dist)

            -- Check if drop is in front of the camera.
            if TransformToLocalPoint(camTr, drop.tr.pos)[3] < 0 then

                local dropPx, dropPy = UiWorldToPixel(drop.tr.pos)

                do UiPush()

                    UiColor(1,1,0, 0.5)
                    UiTranslate(dropPx, dropPy)
                    -- UiImage('ui/common/dot.png')
                    UiAlign('center middle')
                    UiRect(s,s)

                UiPop() end

            end

        end

    UiPop() end

end

function Gas_drops_effects_renderDropIdle(pos)

    ParticleReset()

    -- Idle drop particles.
    ParticleType("smoke")
    ParticleTile(4)
    ParticleColor(0.8,0.8,0)
    ParticleRadius(0.08)
    ParticleAlpha(0.8)
    ParticleGravity(0)
    ParticleDrag(0)
    ParticleEmissive(1)
    ParticleRotation(0)
    ParticleStretch(0)
    ParticleSticky(0)
    ParticleCollide(0)

    SpawnParticle(pos, Vec(), 0.05)

end

function Gas_drops_effects_renderDropBurning(pos)

    ParticleReset()

    local burnThickness = regGetFloat('tool.gas.burnThickness')/4 -- options>>gas

    if regGetBool('tool.gas.ignitionFireParticles') then -- options>>performance

        -- Flame particles.
        ParticleType("smoke")
        ParticleColor(86.0,0.5,0.3, 0.76,0.25,0.1)
        ParticleRadius(burnThickness, burnThickness*3, "linear")
        ParticleTile(5)
        ParticleGravity(0.5)
        ParticleEmissive(4.0, 1, "easein")
        ParticleRotation(rdm(), 0, "linear")
        ParticleStretch(5)
        ParticleCollide(0.5)

        SpawnParticle(pos, Vec(0, 0, 0), 0.5)

    end

    if regGetBool('tool.gas.ignitionSmokeParticles') then -- options>>performance
        -- Smoke particles
        local smokePos = VecAdd(pos, Vec(0,(math.random() + 0.5),0))
        SpawnParticle("darksmoke", smokePos, Vec(0, rdm(2, 3), rdm(1,2), rdm(0.5,1)), 0.5, 0.5, 0.5, 0.5)
    end

end
