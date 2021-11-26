
function initDebug()
    db = regGetBool('tool.debugMode')
end

function dbw(str, value) if db then DebugWatch(str, value) end end
function dbp(str, newLine) if db then DebugPrint(str .. ternary(newLine, '\n', '')) print(str .. ternary(newLine, '\n', '')) end end
function dbl(p1, p2, c1, c2, c3, a) if db then DebugLine(p1, p2, c1, c2, c3, a) end end
function dbdd(pos,w,l,r,g,b,a,dt) DrawDot(pos,w,l,r,g,b,a,dt) end

function debugMod()
    db = regGetBool('tool.debugMode')
    debugGas()
    debugTool()
end

function debugGas()

    dbw('GAS #dropsList', #Gas.dropsList)

    if db then
        for i = 1, #Gas.dropsList do

            local drop = Gas.dropsList[i]

            dbl(GetShapeWorldTransform(drop.sticky.shape).pos, drop.tr.pos, 0,1,0.5, 1)

        end
    end

end

function debugTool()
    dbw('TOOL timers.gun.time', timers.gun.shoot.time)
end
