function modReset()

    regSetFloat('tool.pour.gravity'         , 0.02)
    regSetFloat('tool.pour.rate'            , 1600)
    regSetFloat('tool.pour.spread'          , 10)
    regSetFloat('tool.pour.velocity'        , 0.2)

    regSetFloat('tool.gas.burnTime'         , 2)
    regSetFloat('tool.gas.burnThickness'    , 0.5)
    regSetFloat('tool.gas.ignitionDistance' , 2.2)
    regSetFloat('tool.gas.preburnTime'      , 0.65)
    regSetBool('tool.gas.explosiveVehicles' , true)

    regSetFloat('tool.tool.optionsKey'      , 'o')
    regSetBool('tool.debugMode'             , false)

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

function checkRegInitialized()
    local regInit = GetBool('savegame.mod.regInit')
    if regInit == false then
        modReset()
        SetBool('savegame.mod.regInit', true)
    end
end