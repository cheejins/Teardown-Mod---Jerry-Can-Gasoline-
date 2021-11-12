local db = false
local db = true

function dbw(str, value) if db then DebugWatch(str, value) end end
function dbp(str, newLine) if db then DebugPrint(str .. ternary(newLine, '\n', '')) print(str .. ternary(newLine, '\n', '')) end end
function dbl(p1, p2, c1, c2, c3, a) if db then DebugLine(p1, p2, c1, c2, c3, a) end end
function dbdd(pos,w,l,r,g,b,a,dt) DrawDot(pos,w,l,r,g,b,a,dt) end

function debugMod()
    debugGas()
    debugTool()
end

function debugGas()
    dbw('GAS #dropsList', #Gas.dropsList)
end

function debugTool()
    dbw('TOOL timers.gun.time', timers.gun.shoot.time)
end
