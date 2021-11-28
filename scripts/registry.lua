function modReset()

    regSetFloat('tool.pour.gravity'   , 0.03)
    regSetFloat('tool.pour.rate'      , 1300)
    regSetFloat('tool.pour.spread'    , 7)
    regSetFloat('tool.pour.velocity'  , 0.25)
    regSetBool('tool.debugMode'       , false)
    regSetBool('tool.soundOn'         , true)
    regSetFloat('tool.gas.burnTime'                 , 2)
    regSetFloat('tool.gas.burnThickness'            , 0.6)
    regSetFloat('tool.gas.ignitionDistance'         , 2.2)
    regSetFloat('tool.gas.preburnTime'              , 0.7)
    regSetBool('tool.gas.explosiveVehicles'         , true)
    regSetFloat('tool.gas.explosiveVehiclesDelay'   , 3)
    regSetBool('tool.gas.ignitionFireParticles'   , true)
    regSetBool('tool.gas.ignitionSmokeParticles'  , true)
    regSetBool('tool.gas.renderGasParticles'      , true)

    -- resetToolOptions()
    -- resetGasOptions()
    -- resetPerformanceOptions()
    -- regSetFloat('tool.optionsKey'  , 'o')

end

-- function resetToolOptions()
--     regSetFloat('tool.pour.gravity'   , 0.03)
--     regSetFloat('tool.pour.rate'      , 1300)
--     regSetFloat('tool.pour.spread'    , 7)
--     regSetFloat('tool.pour.velocity'  , 0.25)
--     regSetBool('tool.debugMode'       , false)
--     regSetBool('tool.soundOn'         , true)
-- end

-- function resetGasOptions()
--     regSetFloat('tool.gas.burnTime'                 , 2)
--     regSetFloat('tool.gas.burnThickness'            , 0.6)
--     regSetFloat('tool.gas.ignitionDistance'         , 2.2)
--     regSetFloat('tool.gas.preburnTime'              , 0.7)
--     regSetBool('tool.gas.explosiveVehicles'         , true)
--     regSetFloat('tool.gas.explosiveVehiclesDelay'   , 3)
-- end

-- function resetPerformanceOptions()
--     regSetBool('tool.gas.ignitionFireParticles'   , true)
--     regSetBool('tool.gas.ignitionSmokeParticles'  , true)
--     regSetBool('tool.gas.renderGasParticles'      , true)
-- end


function checkRegInitialized()
    local regInit = GetBool('savegame.mod.regInit')
    if regInit == false then
        modReset()
        SetBool('savegame.mod.regInit', true)
    end
end

function regGetFloat(path)
    local p = 'savegame.mod.' .. path
    return GetFloat(p)
end
function regSetFloat(path, value)
    local p = 'savegame.mod.' .. path
    SetFloat(p, value)
end

function regGetBool(path)
    local p = 'savegame.mod.' .. path
    return GetBool(p)
end
function regSetBool(path, value)
    local p = 'savegame.mod.' .. path
    SetBool(p, value)
end

