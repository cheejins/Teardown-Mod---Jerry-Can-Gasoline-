Gas = {}
Gas.drops = {} -- Holds common data for all drops.
Gas.dropsList = {}

function Gas.run()

    --> Process drops.
    for i = 1, #Gas.dropsList do

        local drop = Gas.dropsList[i]

        -- Main stuff.
        Gas.drops.physics.process(drop)
        Gas.drops.burn.process(drop)

    end

    -- Visual effects.
    Gas.drops.effects.process()

    --> Safely delete specified drops.
    Gas.drops.crud.removeMarkedDrops()

end




Gas.drops.crud = {}

--- Create a drop object and store it in the list of drops.
function Gas.drops.crud.create(tr)

    local drop = {

        id = #Gas.dropsList + 1,
        removeDrop = false, -- true = mark drop for removal/deletion.

        tr = tr,
        rad = 0.2,

        sticky = {
            shape = nil,
            shapeMass = nil,
            shapeRelativePos = nil,
        },

        color = Vec(1,1,1), -- color

        burn = {
            rad = 0.2, -- The radius the drop spawns fire.
            ignitionValid = false, -- Whether a drop is near fire. True = countdown then start burning.
            isBurning = false,
            ignitionDistance = regGetFloat('tool.gas.ignitionDistance'),
        },

        timers = {
            preBurn =   {time = 0, rpm = 60 / regGetFloat('tool.gas.preburnTime')}, -- Once drop is near fire, wait before igniting the drop.
            burn =      {time = 0, rpm = 60 / regGetFloat('tool.gas.burnTime')}, -- Burns regardless of material type.
        }

    }

    -- Drop timer varience.
    drop.timers.burn.rpm = drop.timers.burn.rpm * 1 + (-0.5 + rdm())
    drop.timers.preBurn.rpm = drop.timers.preBurn.rpm * 1 + (-0.5 + rdm())

    -- Drop ignition distance varience.
    drop.burn.ignitionDistance = drop.burn.ignitionDistance * 1 + (-0.5 + rdm())

    -- Initialize time remaining.
    TimerResetTime(drop.timers.preBurn)
    TimerResetTime(drop.timers.burn)

    table.insert(Gas.dropsList, drop)
    dbp('Created drop. ' .. sfnTime())

end

--- Mark a drop for removal to safely remove it near the end of the frame.
function Gas.drops.crud.markDropForRemoval(drop)
    drop.removeDrop = true
    -- dbp('Drop marked.'..sfnTime())
end

--- Safely delete all drops that are marked for removal.
function Gas.drops.crud.removeMarkedDrops()

    local removeIndecies = {}
    if #Gas.dropsList >= 1 then
        for i = 1, #Gas.dropsList do
            if Gas.dropsList[i].removeDrop then
                table.insert(removeIndecies, i)
            end
        end
    end

    for i = 1, #removeIndecies do
        table.remove(Gas.dropsList, removeIndecies[i])
    end

end




Gas.drops.physics = {}

---Process the physics of a single drop.
function Gas.drops.physics.process(drop)

    if drop.sticky.shape == nil then -- Right after gas projectile hits something.

        Gas.drops.physics.sticky.dripAndStick(drop) -- Let the drop drip and find a new shape

    elseif Gas.drops.physics.sticky.didMassDecrease(drop) then -- Drop shape broke previous frame.

        Gas.drops.physics.sticky.dripAndStick(drop) -- QCP right after shape breaks.

    else -- Drop is stuck to a shape and did not break last frame.

        -- Place drop pos relative to shape sticky point.
        drop.tr.pos = TransformToParentPoint(GetShapeWorldTransform(drop.sticky.shape), drop.sticky.shapeRelativePos)

    end

    -- Drop removal.
    drop.sticky.shapeMass = GetBodyMass(GetShapeBody(drop.sticky.shape))

    -- Debug.
    dbw('GAS drop '.. drop.id ..' mass ' .. drop.id, drop.sticky.shapeMass)

end




Gas.drops.physics.sticky = {}

function Gas.drops.physics.sticky.setShape(drop, shape)
    drop.sticky.shape = shape
    drop.sticky.shapeMass = GetBodyMass(GetShapeBody(shape))
    drop.sticky.shapeRelativePos = TransformToLocalPoint(GetShapeWorldTransform(shape), drop.tr.pos)
    dbp('drop shape set ' .. sfnTime())
end

function Gas.drops.physics.sticky.resetShape(drop)
    drop.sticky.shape = nil -- Set no shape
    drop.sticky.shapeMass = nil
    dbp('drop shape reset ' .. sfnTime())
end

function Gas.drops.physics.sticky.didMassDecrease(drop)
    local massDecreased = drop.sticky.shapeMass > GetBodyMass(GetShapeBody(drop.sticky.shape))
    local shapeDestroyed = drop.sticky.shapeMass == nil
    if massDecreased or shapeDestroyed then
        Gas.drops.physics.sticky.resetShape(drop)
        return true
    end
    return false
end

---Check the surroundings of a drop and attach it to very close objects.
function Gas.drops.physics.sticky.dripAndStick(drop)

    --> Check if drop is touching anything.
    local dropRcHit, point, normal, dropRcShape = QueryClosestPoint(drop.tr.pos, 0.2)
    if dropRcHit then

        -- Set shape.
        Gas.drops.physics.sticky.setShape(drop, dropRcShape)

        drop.color = Vec(0,1,0)

    else --> No hit.

        -- Drip down.
        drop.tr.pos = VecAdd(drop.tr.pos, Vec(0, -0.5, 0))

        -- No shape.
        Gas.drops.physics.sticky.resetShape(drop)

        drop.color = Vec(1,0,0)

    end

end




Gas.drops.burn = {}

--- Processes the burning of a drop.
function Gas.drops.burn.process(drop)

    Gas.drops.burn.preBurn(drop)
    Gas.drops.burn.burn(drop)

end

--- Burns a position and applies visual effects. Does not ignite drops.
function Gas.drops.burn.burnPosition(pos)
    SpawnFire(pos)
end

-- Burn after preBurn timer.
function Gas.drops.burn.burn(drop)

    if drop.burn.isBurning then

        local dropIsStillBurning = drop.timers.burn.time > 0
        local dropFinishedBurning = drop.timers.burn.time <= 0

        if dropIsStillBurning then

            Gas.drops.burn.burnPosition(drop.tr.pos)
            TimerRunTime(drop.timers.burn) -- Consume the drop burn timer.

        elseif dropFinishedBurning then

            Gas.drops.crud.markDropForRemoval(drop) -- Delete drop.

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
function Gas.drops.burn.preBurn(drop)


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

--- Handles the core ignition system of the drops (does not process manual spread or burning).
function Gas.drops.burn.spreadFire()

    for i = 1, #Gas.dropsList do

        local drop = Gas.dropsList[i]

        for j = 1, #Gas.dropsList do

            if VecDist(drop, Gas.dropsList[j].tr.pos) < drop.burn.ignitionDistance then

                Gas.drops.burn.igniteDrop(drop)
                return -- Single node of drops only.

            end

        end

    end

end

function Gas.drops.burn.igniteDrop(drop)
    drop.burn.isBurning = true
end

-- function Gas.drops.burn.projectiles()
--     for i = 1, #projectiles do
--         local fireIsClose = QueryClosestFire(projectiles[i].transform.pos, regGetFloat('tool.gas.ignitionDistance'))
--         if fireIsClose then
--             projectiles[i].hit = true
--         end
--     end
-- end




Gas.drops.effects = {}

function Gas.drops.effects.process()

    -- Render drops.
    for i = 1, #Gas.dropsList do

        local drop = Gas.dropsList[i]

        Gas.drops.effects.renderDropIdle(drop.tr.pos) -- Idle drop

        if drop.burn.isBurning then
            Gas.drops.effects.renderDropBurning(drop.tr.pos) -- Burning drop
        end

    end

    -- Render drop projectiles.
    for i = 1, #projectiles do

        local proj = projectiles[i]
        DrawDot(proj.transform.pos, 0.2,0.2, 0.7,0.9,0, 1) -- Drop projectile

    end

end

function Gas.drops.effects.renderDropIdle(pos)

    ParticleReset()

    -- Idle drop particles.
    ParticleType("smoke")
    ParticleTile(4)
    ParticleColor(0.8,0.8,0)
    ParticleRadius(0.08)
    ParticleAlpha(1)
    ParticleGravity(0)
    ParticleDrag(0)
    ParticleEmissive(1)
    ParticleRotation(0)
    ParticleStretch(0)
    ParticleSticky(0)
    ParticleCollide(0)

    SpawnParticle(pos, Vec(), 0.08)

    DrawDot(pos, 0.2,0.2, 0.7,0.9,0, 1)

end

function Gas.drops.effects.renderDropBurning(pos)

    ParticleReset()

    -- Flame particles.
    ParticleType("smoke")
    ParticleColor(86.0,0.5,0.3, 0.76,0.25,0.1)
    ParticleRadius(0.2, 0.5, "linear")
    ParticleTile(5)
    ParticleGravity(0.5)
    ParticleEmissive(4.0, 1, "easein")
    ParticleRotation(rdm(), 0, "linear")
    ParticleStretch(5)
    ParticleCollide(0.5)
    SpawnParticle(pos, Vec(0, 0, 0), 1)

    -- Smoke particles
    local smokePos = VecAdd(pos, Vec(0,math.random() + 0.5,0))
    SpawnParticle("darksmoke", smokePos, Vec(0, rdm(2, 3), rdm(1,2), rdm(0.5,1)), 0.5, 0.5, 0.5, 0.5)

end
