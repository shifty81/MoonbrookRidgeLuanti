-- mbr_particles: Visual particle effects for tool actions and gameplay

-- =============================================================================
-- Particle Namespace
-- =============================================================================

mbr.particles = {}

-- =============================================================================
-- Particle Type Definitions
-- =============================================================================

local particle_defs = {
	dirt = {
		texture = "[fill:4x4:#8B6914",
		amount = 12,
		time = 0.5,
		minpos = {x = -0.3, y = 0.0, z = -0.3},
		maxpos = {x = 0.3, y = 0.2, z = 0.3},
		minvel = {x = -1, y = 2, z = -1},
		maxvel = {x = 1, y = 4, z = 1},
		minacc = {x = 0, y = -9.8, z = 0},
		maxacc = {x = 0, y = -9.8, z = 0},
		minexptime = 0.5,
		maxexptime = 1.0,
		minsize = 1.0,
		maxsize = 2.0,
	},
	water = {
		texture = "[fill:3x3:#4488DD",
		amount = 10,
		time = 0.5,
		minpos = {x = -0.2, y = 0.0, z = -0.2},
		maxpos = {x = 0.2, y = 0.3, z = 0.2},
		minvel = {x = -1.5, y = 1, z = -1.5},
		maxvel = {x = 1.5, y = 3, z = 1.5},
		minacc = {x = 0, y = -9.8, z = 0},
		maxacc = {x = 0, y = -9.8, z = 0},
		minexptime = 0.3,
		maxexptime = 0.8,
		minsize = 0.5,
		maxsize = 1.5,
	},
	rock = {
		texture = "[fill:4x4:#888888",
		amount = 15,
		time = 0.5,
		minpos = {x = -0.3, y = -0.1, z = -0.3},
		maxpos = {x = 0.3, y = 0.3, z = 0.3},
		minvel = {x = -2, y = 1, z = -2},
		maxvel = {x = 2, y = 4, z = 2},
		minacc = {x = 0, y = -9.8, z = 0},
		maxacc = {x = 0, y = -9.8, z = 0},
		minexptime = 0.5,
		maxexptime = 1.2,
		minsize = 1.0,
		maxsize = 2.5,
	},
	wood = {
		texture = "[fill:4x3:#C4A05A",
		amount = 10,
		time = 0.5,
		minpos = {x = -0.3, y = -0.1, z = -0.3},
		maxpos = {x = 0.3, y = 0.3, z = 0.3},
		minvel = {x = -2, y = 1, z = -2},
		maxvel = {x = 2, y = 3, z = 2},
		minacc = {x = 0, y = -9.8, z = 0},
		maxacc = {x = 0, y = -9.8, z = 0},
		minexptime = 0.4,
		maxexptime = 1.0,
		minsize = 0.8,
		maxsize = 2.0,
	},
	sparkle = {
		texture = "[fill:3x3:#FFD700",
		amount = 15,
		time = 0.8,
		minpos = {x = -0.4, y = 0.0, z = -0.4},
		maxpos = {x = 0.4, y = 0.5, z = 0.4},
		minvel = {x = -0.5, y = 1, z = -0.5},
		maxvel = {x = 0.5, y = 3, z = 0.5},
		minacc = {x = 0, y = -1, z = 0},
		maxacc = {x = 0, y = 0, z = 0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 0.5,
		maxsize = 1.5,
		glow = 8,
	},
	splash = {
		texture = "[fill:3x3:#5599EE",
		amount = 20,
		time = 0.5,
		minpos = {x = -0.5, y = -0.1, z = -0.5},
		maxpos = {x = 0.5, y = 0.1, z = 0.5},
		minvel = {x = -3, y = 1, z = -3},
		maxvel = {x = 3, y = 3, z = 3},
		minacc = {x = 0, y = -9.8, z = 0},
		maxacc = {x = 0, y = -9.8, z = 0},
		minexptime = 0.3,
		maxexptime = 0.8,
		minsize = 0.5,
		maxsize = 1.0,
	},
	heart = {
		texture = "[fill:4x4:#FF6688",
		amount = 5,
		time = 1.0,
		minpos = {x = -0.3, y = 0.5, z = -0.3},
		maxpos = {x = 0.3, y = 1.0, z = 0.3},
		minvel = {x = -0.3, y = 0.5, z = -0.3},
		maxvel = {x = 0.3, y = 1.5, z = 0.3},
		minacc = {x = 0, y = 0.2, z = 0},
		maxacc = {x = 0, y = 0.5, z = 0},
		minexptime = 1.0,
		maxexptime = 2.0,
		minsize = 1.5,
		maxsize = 2.5,
		glow = 5,
	},
	levelup = {
		texture = "[fill:3x3:#FFD700",
		amount = 20,
		time = 1.0,
		minpos = {x = -0.5, y = 0.0, z = -0.5},
		maxpos = {x = 0.5, y = 0.5, z = 0.5},
		minvel = {x = -1, y = 2, z = -1},
		maxvel = {x = 1, y = 5, z = 1},
		minacc = {x = 0, y = 0.5, z = 0},
		maxacc = {x = 0, y = 1.0, z = 0},
		minexptime = 1.0,
		maxexptime = 2.5,
		minsize = 1.0,
		maxsize = 2.0,
		glow = 10,
	},
	damage = {
		texture = "[fill:3x3:#CC2222",
		amount = 10,
		time = 0.5,
		minpos = {x = -0.3, y = 0.0, z = -0.3},
		maxpos = {x = 0.3, y = 1.0, z = 0.3},
		minvel = {x = -2, y = 0, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = 0, y = -5, z = 0},
		maxacc = {x = 0, y = -3, z = 0},
		minexptime = 0.3,
		maxexptime = 0.7,
		minsize = 0.8,
		maxsize = 1.5,
	},
	heal = {
		texture = "[fill:3x3:#44DD44",
		amount = 8,
		time = 0.8,
		minpos = {x = -0.3, y = 0.0, z = -0.3},
		maxpos = {x = 0.3, y = 0.5, z = 0.3},
		minvel = {x = -0.3, y = 1, z = -0.3},
		maxvel = {x = 0.3, y = 3, z = 0.3},
		minacc = {x = 0, y = 0.5, z = 0},
		maxacc = {x = 0, y = 1.0, z = 0},
		minexptime = 0.8,
		maxexptime = 1.5,
		minsize = 1.0,
		maxsize = 2.0,
		glow = 6,
	},
}

-- =============================================================================
-- Spawn Function
-- =============================================================================

function mbr.particles.spawn(pos, particle_type)
	local def = particle_defs[particle_type]
	if not def then
		core.log("warning", "[mbr_particles] Unknown particle type: " .. tostring(particle_type))
		return
	end

	core.add_particlespawner({
		amount = def.amount,
		time = def.time,
		minpos = {x = pos.x + def.minpos.x, y = pos.y + def.minpos.y, z = pos.z + def.minpos.z},
		maxpos = {x = pos.x + def.maxpos.x, y = pos.y + def.maxpos.y, z = pos.z + def.maxpos.z},
		minvel = def.minvel,
		maxvel = def.maxvel,
		minacc = def.minacc,
		maxacc = def.maxacc,
		minexptime = def.minexptime,
		maxexptime = def.maxexptime,
		minsize = def.minsize,
		maxsize = def.maxsize,
		texture = def.texture,
		collisiondetection = true,
		glow = def.glow,
	})
end

-- =============================================================================
-- Auto-spawn on Node Dig
-- =============================================================================

core.register_on_dignode(function(pos, oldnode)
	local node_def = core.registered_nodes[oldnode.name]
	if not node_def then return end

	local groups = node_def.groups or {}

	if groups.cracky then
		mbr.particles.spawn(pos, "rock")
	elseif groups.choppy then
		mbr.particles.spawn(pos, "wood")
	elseif groups.crumbly then
		mbr.particles.spawn(pos, "dirt")
	end
end)

core.log("action", "[mbr_particles] Loaded.")
