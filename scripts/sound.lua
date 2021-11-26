function initSounds()

    sounds = {

        pour = LoadLoop("MOD/snd/pour.ogg"),

        drops = {
            LoadSound("MOD/snd/drops/drop1.ogg"),
            LoadSound("MOD/snd/drops/drop2.ogg"),
            LoadSound("MOD/snd/drops/drop3.ogg"),
            LoadSound("MOD/snd/drops/drop4.ogg"),
        },

    }

    sounds.play = {

        pour = function(pos, vol)
            PlayLoop(sounds.pour, pos, vol or 1)
        end,

        drop = function(pos, vol)
            sounds.playRandom(pos, sounds.drops, vol or 1)
        end,

    }

    sounds.playRandom = function(pos, soundsTable, vol)
        local p = math.floor(soundsTable[rdm(1, #soundsTable)])
        PlaySound(p, pos, vol or 1)
    end

end
