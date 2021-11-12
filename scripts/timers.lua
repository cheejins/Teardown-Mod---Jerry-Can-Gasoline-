timers = {}
timer = {time, rpm}


-- Timers that count down constantly.
function runTimers()
    TimerRunTime(timers.gun.shoot)
    TimerRunTime(timers.gas.spread)
end


timers.gun = { shoot = { time = 0, rpm = 1200 } }
timers.gas = { spread = { time = 0, rpm = 150 } }


-- TimerAddTimer(timers.gun, time, rpm)