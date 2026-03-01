mbr = mbr or {}

mbr.particles = {}

local effect_defs = {
	dirt = {
		texture = "[fill:4x4:#8B4513",
		amount = 8,
		minvel = {x = -1, y = 1, z = -1},
		maxvel = {x = 1, y = 3, z = 1},
		minacc = {x = 0, y = -9.81, z = 0},
		maxacc = {x = 0, y = -9.81, z = 0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 1.0,
		maxsize = 2.0,
		minpos_offset = {x = -0.3, y = 0, z = -0.3},
		maxpos_offset = {x = 0.3, y = 0.5, z = 0.3},
	},
	water = {
		texture = "[fill:4x4:#4169E1",
		amount = 10,
		minvel = {x = -2, y = 1, z = -2},
		maxvel = {x = 2, y = 4, z = 2},
		minacc = {x = 0, y = -9.81, z = 0},
		maxacc = {x = 0, y = -9.81, z = 0},
		minexptime = 0.3,
		maxexptime = 1.0,
		minsize = 0.5,
		maxsize = 1.5,
		minpos_offset = {x = -0.4, y = 0, z = -0.4},
		maxpos_offset = {x = 0.4, y = 0.3, z = 0.4},
	},
	rock = {
		texture = "[fill:4x4:#808080",
		amount = 6,
		minvel = {x = -2, y = 0.5, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = {x = 0, y = -9.81, z = 0},
		maxacc = {x = 0, y = -9.81, z = 0},
		minexptime = 0.5,
		maxexptime = 1.2,
		minsize = 0.8,
		maxsize = 1.5,
		minpos_offset = {x = -0.3, y = 0, z = -0.3},
		maxpos_offset = {x = 0.3, y = 0.5, z = 0.3},
	},
	wood = {
		texture = "[fill:4x4:#DEB887",
		amount = 8,
		minvel = {x = -1.5, y = 0.5, z = -1.5},
		maxvel = {x = 1.5, y = 2.5, z = 1.5},
		minacc = {x = 0, y = -9.81, z = 0},
		maxacc = {x = 0, y = -9.81, z = 0},
		minexptime = 0.4,
		maxexptime = 1.2,
		minsize = 0.8,
		maxsize = 1.8,
		minpos_offset = {x = -0.3, y = 0, z = -0.3},
		maxpos_offset = {x = 0.3, y = 0.5, z = 0.3},
	},
	sparkle = {
		texture = "[fill:4x4:#FFD700",
		amount = 12,
		minvel = {x = -0.5, y = 0.5, z = -0.5},
		maxvel = {x = 0.5, y = 2, z = 0.5},
		minacc = {x = 0, y = 0.2, z = 0},
		maxacc = {x = 0, y = 0.5, z = 0},
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = 0.5,
		maxsize = 1.2,
		minpos_offset = {x = -0.3, y = 0, z = -0.3},
		maxpos_offset = {x = 0.3, y = 0.5, z = 0.3},
		glow = 8,
	},
	splash = {
		texture = "[fill:4x4:#1E90FF",
		amount = 15,
		minvel = {x = -3, y = 0.2, z = -3},
		maxvel = {x = 3, y = 1.5, z = 3},
		minacc = {x = 0, y = -9.81, z = 0},
		maxacc = {x = 0, y = -9.81, z = 0},
		minexptime = 0.3,
		maxexptime = 0.8,
		minsize = 0.5,
		maxsize = 1.5,
		minpos_offset = {x = -0.5, y = 0, z = -0.5},
		maxpos_offset = {x = 0.5, y = 0.1, z = 0.5},
	},
	heart = {
		texture = "[fill:4x4:#FF69B4",
		amount = 5,
		minvel = {x = -0.3, y = 0.5, z = -0.3},
		maxvel = {x = 0.3, y = 1.2, z = 0.3},
		minacc = {x = 0, y = 0.1, z = 0},
		maxacc = {x = 0, y = 0.3, z = 0},
		minexptime = 1.0,
		maxexptime = 2.5,
		minsize = 1.0,
		maxsize = 2.0,
		minpos_offset = {x = -0.2, y = 0.5, z = -0.2},
		maxpos_offset = {x = 0.2, y = 1.0, z = 0.2},
		glow = 5,
	},
	levelup = {
		texture = "[fill:4x4:#FFD700",
		amount = 20,
		minvel = {x = -1, y = 1, z = -1},
		maxvel = {x = 1, y = 3, z = 1},
		minacc = {x = -0.5, y = 0.5, z = -0.5},
		maxacc = {x = 0.5, y = 1.0, z = 0.5},
		minexptime = 1.0,
		maxexptime = 2.5,
		minsize = 0.8,
		maxsize = 1.8,
		minpos_offset = {x = -0.5, y = 0, z = -0.5},
		maxpos_offset = {x = 0.5, y = 1.0, z = 0.5},
		glow = 10,
	},
	damage = {
		texture = "[fill:4x4:#FF0000",
		amount = 8,
		minvel = {x = -2, y = 1, z = -2},
		maxvel = {x = 2, y = 3, z = 2},
		minacc = {x = 0, y = -5, z = 0},
		maxacc = {x = 0, y = -5, z = 0},
		minexptime = 0.3,
		maxexptime = 0.8,
		minsize = 0.8,
		maxsize = 1.5,
		minpos_offset = {x = -0.3, y = 0.5, z = -0.3},
		maxpos_offset = {x = 0.3, y = 1.2, z = 0.3},
	},
	heal = {
		texture = "[fill:4x4:#00FF00",
		amount = 10,
		minvel = {x = -0.5, y = 0.5, z = -0.5},
		maxvel = {x = 0.5, y = 2, z = 0.5},
		minacc = {x = 0, y = 0.2, z = 0},
		maxacc = {x = 0, y = 0.5, z = 0},
		minexptime = 0.8,
		maxexptime = 1.8,
		minsize = 0.8,
		maxsize = 1.5,
		minpos_offset = {x = -0.3, y = 0, z = -0.3},
		maxpos_offset = {x = 0.3, y = 1.0, z = 0.3},
		glow = 6,
	},
}

function mbr.particles.spawn(pos, effect_type, player)
	local def = effect_defs[effect_type]
	if not def then
		return nil
	end

	local spawner_def = {
		amount = def.amount,
		time = 0.5,
		minpos = {
			x = pos.x + def.minpos_offset.x,
			y = pos.y + def.minpos_offset.y,
			z = pos.z + def.minpos_offset.z,
		},
		maxpos = {
			x = pos.x + def.maxpos_offset.x,
			y = pos.y + def.maxpos_offset.y,
			z = pos.z + def.maxpos_offset.z,
		},
		minvel = def.minvel,
		maxvel = def.maxvel,
		minacc = def.minacc,
		maxacc = def.maxacc,
		minexptime = def.minexptime,
		maxexptime = def.maxexptime,
		minsize = def.minsize,
		maxsize = def.maxsize,
		texture = def.texture,
	}

	if def.glow then
		spawner_def.glow = def.glow
	end

	if player then
		spawner_def.playername = player:get_player_name()
		return core.add_particlespawner(spawner_def)
	end

	-- Spawn for all nearby players (within 32 nodes)
	local ids = {}
	for _, p in ipairs(core.get_connected_players()) do
		local ppos = p:get_pos()
		local dist = vector.distance(pos, ppos)
		if dist <= 32 then
			local pdef = table.copy(spawner_def)
			pdef.playername = p:get_player_name()
			ids[#ids + 1] = core.add_particlespawner(pdef)
		end
	end
	return ids
end

-- Node group to particle effect mapping
local group_effects = {
	cracky = "rock",
	choppy = "wood",
	crumbly = "dirt",
	snappy = "sparkle",
}

core.register_on_dignode(function(pos, oldnode, digger)
	if not oldnode or not oldnode.name then
		return
	end

	local node_def = core.registered_nodes[oldnode.name]
	if not node_def or not node_def.groups then
		return
	end

	for group, effect in pairs(group_effects) do
		if node_def.groups[group] and node_def.groups[group] > 0 then
			mbr.particles.spawn(pos, effect, digger)
			return
		end
	end
end)
