function modReset()

    regSetFloat('tool.pour.gravity'         , 0.02)
    regSetFloat('tool.pour.rate'            , 1200)
    regSetFloat('tool.pour.velocity'        , 0.065)
    regSetFloat('tool.pour.spread'          , 10)

    regSetFloat('tool.gas.ignitionDistance' , 2.2)
    regSetFloat('tool.gas.burnTime'         , 2)
    regSetFloat('tool.gas.preburnTime'      , 0.5)

end

function regGetFloat(path)
    local p = 'savegame.mod.' .. path
    return GetFloat(p)
end

function regSetFloat(path, value)
    local p = 'savegame.mod.' .. path
    SetFloat(p, value)
end