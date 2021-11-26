timers = {}
timer = {time, rpm}

-- Timers that count down constantly.
function runTimers()
    TimerRunTime(timers.gun.shoot)
    TimerRunTime(timers.gas.spread)
end

function initTimers()
    timers.gun = { shoot = { time = 0, rpm = regGetFloat('tool.pour.rate') } }
    timers.gas = { spread = { time = 0, rpm = 150 } }
end
