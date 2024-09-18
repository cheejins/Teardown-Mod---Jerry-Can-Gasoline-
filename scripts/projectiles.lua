#include "registry.lua"

projectiles = {}

function manageProjectiles()

    manageActiveProjs(projectiles)

    projPresets = {
        gasCan = {
            isActive = true, -- Active when firing, inactive after hit.
            hit = false,
            lifeLength = 10, --Seconds

            speed = regGetFloat('tool.pour.velocity'),
            drop = regGetFloat('tool.pour.velocity') * regGetFloat('tool.pour.gravity'),
            dropIncrement = regGetFloat('tool.pour.gravity')/10,

            particle = 'smoke',

            particleColor = Vec(1, 1, 1),
            explosive = 0,
            sound = nil,
        },
    }


end

--[[Projectiles]]
function createProj(transform, projectiles, projPreset, ignoreBodies) --- Instantiates a proj and adds it to the projectiles table.
    local proj = TableClone(projPreset)
    proj.transform = transform
    proj.ignoreBodies = ignoreBodies

    table.insert(projectiles, proj)
end

function manageActiveProjs(projectiles)
    -- if #projectiles > 0 then

        local projsToRemove = {} -- projectiles iterations.
        for i = 1, #projectiles do

            local proj = projectiles[i]
            if proj.isActive and proj.hit == false then

                propelProj(proj)

                proj.lifeLength = proj.lifeLength - GetTimeStep()
                if proj.lifeLength <= 0 then
                    proj.isActive = false
                    proj.hit = true
                end

            elseif proj.isActive == false or proj.hit then -- if proj is inactive.
                table.insert(projsToRemove, i)
                -- DebugPrint("Insert proj " .. i)
            end
        end

        for i = 1, #projsToRemove do -- remove proj from active projs after projectiles iterations.
            table.remove(projectiles, projsToRemove[i]) -- remove active projs
            -- DebugPrint("Removed proj " .. i)
        end
    -- end
end

function propelProj(proj)

    if proj.ignoreBodies ~= nil then
        for i = 1, #proj.ignoreBodies do
            QueryRejectBody(proj.ignoreBodies[i])
        end
    end

    -- Proj hit shape.
    local pos = proj.transform.pos
    local dir = VecSub(proj.transform.pos, TransformToParentPoint(proj.transform, Vec(0,0,-1)))
    local dist = proj.speed
    local radius = 0.1
    local hit, dist, hitShape = QueryRaycast(pos, dir, dist, radius)
    if hit then

        local hitPos = TransformToParentPoint(proj.transform, Vec(0,0,dist))
        proj.hit = true

        Gas_drops_crud_spawn(hitPos)

    end

    -- Proj hit water.
    if IsPointInWater(proj.transform.pos) then
        proj.hit = true
        SpawnParticle("water", proj.transform.pos, Vec(0,0,0), 3, 1)
    end

    -- Proj life.
    if proj.hit then
        proj.isActive = false
    else
        proj.isActive = true
    end

    -- Move proj forward.
    proj.transform.pos = TransformToParentPoint(proj.transform, Vec(0,0,-proj.speed))
    proj.transform.pos = VecAdd(proj.transform.pos, Vec(0,-proj.drop,0))
    proj.drop = proj.drop + proj.dropIncrement

end

