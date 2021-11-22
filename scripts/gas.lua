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
        -- Gas.drops.burn.spreadFire()


        -- Visual effects.
        Gas.drops.visuals.process(drop)
        -- DrawDot(drop.tr.pos, 0.2,0.2, drop.color[1],drop.color[2],drop.color[3], 1, false) -- Draw colored dot at drop pos.
        -- DrawShapeOutline(drop.sticky.shape, 1,0.5,1, 1)
        -- DrawBodyOutline(GetShapeBody(drop.sticky.shape), 1,1,0, 0.5)

    end

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
        rad = 0.3,

        sticky = {
            shape = nil,
            shapeMass = nil,
            shapeRelativePos = nil,
        },

        color = Vec(1,1,1), -- color

        burn = {
            ignitionValid = false, -- Whether a drop is near fire. True = countdown then start burning.
            isBurning = false,
            ignitionDistance = 2,
        },

        timers = {
            preBurn = {time = 0, rpm = 150}, -- Once drop is near fire, wait before igniting the drop.
            burn = {time = 0, rpm = 150}, -- Burns regardless of material type.
        }

    }

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

        -- PointLight(drop.tr.pos, 1,0,0, 1)

    else -- Drop is stuck to a shape and did not break last frame.

        -- Place drop pos relative to shape sticky point.
        drop.tr.pos = TransformToParentPoint(GetShapeWorldTransform(drop.sticky.shape), drop.sticky.shapeRelativePos)

        dbw('GAS drop pos ', drop.tr.pos)
        dbw('GAS drop shape mass ' .. drop.id, drop.sticky.shapeMass)
        dbw('GAS drop.sticky.shapeRelativePos', drop.sticky.shapeRelativePos)

        -- PointLight(drop.tr.pos, 0,1,0.5, 1)

    end

    -- Drop removal.
    drop.sticky.shapeMass = GetBodyMass(GetShapeBody(drop.sticky.shape))

    -- Debug.
    dbl(GetShapeWorldTransform(drop.sticky.shape).pos, drop.tr.pos, 0,1,0.5, 1)
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

    -- dbp('Checking drop QCP ' .. sfnTime())

    -- --> Check if drop is touching anything.
    -- local a = 0.05
    -- local queryPositions = {
    --     VecAdd(drop.tr.pos, Vec(a,a,a)),
    --     VecAdd(drop.tr.pos, Vec(-a,-a,-a))}

    -- AabbDraw(queryPositions[1],queryPositions[2], 1,1,1, 1)

    -- local shapeList = QueryAabbShapes(queryPositions[1], queryPositions[2])
    -- if #shapeList <= 0 then

    --     -- Set shape.
    --     Gas.drops.physics.sticky.setShape(drop, shapeList[1])

    --     drop.color = Vec(0,1,0)

    -- else --> No hit.

    --     -- Drip down.
    --     drop.tr.pos = VecAdd(drop.tr.pos, Vec(0, -0.5, 0))

    --     -- No shape.
    --     Gas.drops.physics.sticky.resetShape(drop)

    --     drop.color = Vec(1,0,0)

    -- end

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
    SpawnParticle("darksmoke", pos, Vec(0,0.5,0), 0.5, 0.5, 0.5, 0.5)
    SpawnParticle("darksmoke", pos, rdmVec(), 0.5, 0.5, 0.5, 0.5)
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

function Gas.drops.burn.igniteDropsNearFire()

    if timers.gas.spread.time <= 0 then
        timers.gas.spread.time = 60/timers.gas.spread.rpm

        for i = 1, #Gas.dropsList do
            Gas.drops.burn.igniteDropNearFire(Gas.dropsList[i])
        end
    end

end

function Gas.drops.burn.igniteDropNearFire(drop)

    --> Ignite nearby fires.
    local fireIsClose = QueryClosestFire(drop.tr.pos, drop.burn.ignitionDistance)
    if fireIsClose then

        Gas.drops.burn.igniteDrop(drop)
        drop.color = Vec(1,0.5,0)

        -- Gas.drops.burn.burnPosition(drop.tr.pos)
        Gas.drops.crud.markDropForRemoval(drop)

    end

end



Gas.drops.visuals = {}

function Gas.drops.visuals.process(drop)

    ParticleReset()
    ParticleType("smoke")
    ParticleTile(4)
    ParticleColor(0.8,0.8,0)
    ParticleRadius(0.05)
    ParticleAlpha(1)
    ParticleGravity(0)
    ParticleDrag(0)
    ParticleEmissive(1)
    ParticleRotation(0)
    ParticleStretch(0)
    ParticleSticky(0)
    ParticleCollide(1)

    SpawnParticle(drop.tr.pos, Vec(), 0.1)

end