-- Load translation library if intllib is installed

local S
if (minetest.get_modpath("intllib")) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	S = intllib.Getter(minetest.get_current_modname())
	else
	S = function ( s ) return s end
end

-- xPanes mod by xyz

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

pane_directions = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
}

function update_nearby_panes(pos)
	for i = 1,4 do
		update_pane_glass({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
	end
end

local half_blocks = {
	{0, -0.5, -0.06, 0.5, 0.5, 0.06},
	{-0.06, -0.5, 0, 0.06, 0.5, 0.5},
	{-0.5, -0.5, -0.06, 0, 0.5, 0.06},
	{-0.06, -0.5, -0.5, 0.06, 0.5, 0}
}

local full_blocks = {
	{-0.5, -0.5, -0.06, 0.5, 0.5, 0.06},
	{-0.06, -0.5, -0.5, 0.06, 0.5, 0.5}
}

function register_pane(modname, subname, recipeitem, light, walkable, description)
	for i = 1, 15 do
		local need = {}
		local cnt = 0
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				need[j] = true
				cnt = cnt + 1
			end
		end
		local take = {}
		if need[1] == true and need[3] == true then
			need[1] = nil
			need[3] = nil
			table.insert(take, full_blocks[1])
		end
		if need[2] == true and need[4] == true then
			need[2] = nil
			need[4] = nil
			table.insert(take, full_blocks[2])
		end
		for k in pairs(need) do
			table.insert(take, half_blocks[k])
		end
		local texture = modname .. "_" .. subname .. ".png"
		if cnt == 1 then
			texture = modname .. "_pane_" .. subname .. "_half.png"
		end

		minetest.register_node(modname .. ":pane_" .. subname .. "_" .. i, {
			drawtype = "nodebox",
			description = S("%s Pane"):format(S(description)),
			tile_images = {modname .. "_pane_" .. subname .. "_half.png", modname .. "_pane_" .. subname .. "_half.png", texture},
			paramtype = "light",
			walkable = walkable,
			light_source = light,
			groups = {snappy=2,cracky=3,oddly_breakable_by_hand=3},
			drop = modname .. ":pane_" .. subname,
			sunlight_propagates = true,
			sounds = default.node_sound_glass_defaults(),
			node_box = {
				type = "fixed",
				fixed = take
			},
			selection_box = {
				type = "fixed",
				fixed = take
			}
		})
	end

	minetest.register_node(modname .. ":pane_" .. subname, {
		description = S("%s Pane"):format(S(description)),
		drawtype = airlike,
		inventory_image = modname .. "_" .. subname .. ".png",
		paramtype = "light",
		walkable = false,
		light_source = light,
		sunlight_propagates = true,
		drop = modname .. ":pane_" .. subname,
		wield_image = modname .. "_" .. subname .. ".png",
		node_placement_prediction = modname .. ":pane_" .. subname .. "_15",
		sounds = default.node_sound_glass_defaults(),
		on_construct = update_pane_glass
	})

	minetest.register_craft({
		output = modname .. ":pane_" .. subname .. " 16",
		recipe = {
			{recipeitem, recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem}
		}
	})

	minetest.register_on_placenode(update_nearby_panes)
	minetest.register_on_dignode(update_nearby_panes)
end

-- xFences mod by xyz
-- most code is taken from xPanes

local replace_default_fences = false

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local function merge(lhs, rhs)
	local merged_table = {}
	for _, v in ipairs(lhs) do
		table.insert(merged_table, v)
	end
	for _, v in ipairs(rhs) do
		table.insert(merged_table, v)
	end
	return merged_table
end

local directions = {
	{x = 1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = -1},
}

function update_fence(pos)
	if minetest.env:get_node(pos).name:find("moreblocks:fence_wood") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	minetest.env:add_node(pos, {name = "moreblocks:fence_wood_"..sum})
end

function update_nearby_fences(pos)
	for i = 1,4 do
		update_fence({x = pos.x + directions[i].x, y = pos.y + directions[i].y, z = pos.z + directions[i].z})
	end
end

local blocks = {
	{{0, 0.25, -0.06, 0.5, 0.4, 0.06}, {0, -0.15, -0.06, 0.5, 0, 0.06}},
	{{-0.06, 0.25, 0, 0.06, 0.4, 0.5}, {-0.06, -0.15, 0, 0.06, 0, 0.5}},
	{{-0.5, 0.25, -0.06, 0, 0.4, 0.06}, {-0.5, -0.15, -0.06, 0, 0, 0.06}},
	{{-0.06, 0.25, -0.5, 0.06, 0.4, 0}, {-0.06, -0.15, -0.5, 0.06, 0, 0}}
}

local limiters = {
	{{0, 1.0, -0.1, 0.5, 1.0, -0.0999}, {0, 1.0, 0.0999, 0.5, 1.0, 0.1}},
	{{-0.1, 1.0, 0, -0.0999, 1.0, 0.5}, {0.0999, 1.0, 0, 0.1, 1.0, 0.5}},
	{{-0.5, 1.0, -0.1, 0, 1.0, -0.0999}, {-0.5, 1.0, 0.0999, 0, 1.0, 0.1}},
	{{-0.1, 1.0, -0.5, -0.0999, 1.0, 0}, {0.0999, 1.0, -0.5, 0.1, 1.0, 0}},
}

local base = {-0.1, -0.5, -0.1, 0.1, 0.5, 0.1}

function register_fence(modname, subname, recipeitem, light, walkable, description)
	for i = 0, 15 do
		local take = {base}
		local take_with_limits = {base}
		for j = 1, 4 do
			if rshift(i, j - 1) % 2 == 1 then
				take = merge(take, blocks[j])
				take_with_limits = merge(take_with_limits, merge(blocks[j], limiters[j]))
			end
		end
	
		local texture = modname .. "_" .. subname .. ".png"
		minetest.register_node(modname .. ":fence_" .. subname .. "_" .. i, {
			drawtype = "nodebox",
			tile_images = {texture},
			paramtype = "light",
			walkable = walkable,
			light_source = light,
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2},
			drop = modname .. ":fence_" .. subname,
			sunlight_propagates = true,
			node_box = {
				type = "fixed",
				fixed = take_with_limits
			},
			selection_box = {
				type = "fixed",
				fixed = take
			},
			sounds = default.node_sound_wood_defaults(),
		})
	end
	
	minetest.register_node(modname .. ":fence_" .. subname, {
	description = S("%s Fence"):format(S(description)),
	drawtype = airlike,
	inventory_image = modname .."_fence_" .. subname .. ".png",
	paramtype = "light",
	light_source = light,
	walkable = false,
	sunlight_propagates = true,
	wield_image = modname .."_fence_" .. subname .. ".png",
	node_placement_prediction = "moreblocks:fence_wood_1",
	on_construct = update_fence
	})
	
	minetest.register_craft({
		output = "moreblocks:fence_wood 2",
		recipe = {
			{"moreblocks:jungle_stick", "moreblocks:jungle_stick", "moreblocks:jungle_stick"},
			{"moreblocks:jungle_stick", "moreblocks:jungle_stick", "moreblocks:jungle_stick"}
		}
	})
end

register_fence("moreblocks", "wood", "default:stick", 0, true, "Wooden")
register_fence("moreblocks", "jungle_wood", "moreblocks:jungle_stick", 0, true, "Jungle Wood")
