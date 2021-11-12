Particles = {

    ---@param p table -- Particle preset
    setParticle = function(p)
        ParticleReset()

        ParticleColor(p.r, p.g, p.b)
        ParticleAlpha(p.a[1], p.a[2])

        ParticleEmissive(p.emis[1], p.emis[2])
        ParticleDrag(0, 0.3)
        ParticleTile(p.tile)

        ParticleRadius(p.rad[1], p.rad[2])
        ParticleGravity(p.grav[1], p.grav[2])
        ParticleCollide(p.coll)
    end,

    ---comment
    ---@param r any
    ---@param g any
    ---@param b any
    ---@param a any
    ---@param emmis 
    ---@param drag any
    ---@param tile any
    ---@param rad any
    ---@param grav any
    ---@param coll any
    ---@param stretch any
    ---@param sticky any
    ---@param rotation any
    ---@param type any
    ---@param flags any
    ---@return table
    create = function(r,g,b,a, emmis,drag,tile, rad,grav,coll,stretch,sticky,rotation, type,flags)
        return {

            r = r,
            g = g,
            b = b,
            a = a,
            emmis = emmis,

            drag = drag,
            tile = tile,
            rad = rad,
            grav = grav,
            coll = coll,
            stretch = stretch,
            sticky = sticky,
            rotation = rotation,

            type = type,
            flags = flags,

        }
    end,

    preset = {


        -- modify = {

        --     color = function(p, r,g,b,a)
        --         p.r = r
        --         p.g = g
        --         p.b = b
        --         p.a = a
        --     end,

        -- }

    },

}


Particles.presets = {

    default = {
        stream = Particles.create(1,1,1,1, 1,1,1, 0.2,0,),
    },

    gas = {
    }

}
