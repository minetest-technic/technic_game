function update_pane_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_glass_" .. sum})
end


function update_pane_coal_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_coal_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_coal_glass_" .. sum})
end


function update_pane_iron_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_iron_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_iron_glass_" .. sum})
end


function update_pane_clean_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_clean_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_clean_glass_" .. sum})
end


function update_pane_trap_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_trap_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_trap_glass_" .. sum})
end


function update_pane_glow_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_glow_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_glass_" .. sum})
end

function update_pane_super_glow_glass(pos, modname, subname)
	if minetest.env:get_node(pos).name:find("moreblocks:pane_super_glow_glass") == nil then
		return
	end
	local sum = 0
	for i = 1, 4 do
		local node = minetest.env:get_node({x = pos.x + pane_directions[i].x, y = pos.y + pane_directions[i].y, z = pos.z + pane_directions[i].z})
		if minetest.registered_nodes[node.name].walkable ~= false then
			sum = sum + 2 ^ (i - 1)
		end
	end
	if sum == 0 then
		sum = 15
	end
	minetest.env:add_node(pos, {name = "moreblocks:pane_super_glow_glass_" .. sum})
end

register_pane("moreblocks", "glass", "default:glass", 0, true, "Glass")
register_pane("moreblocks", "coal_glass", "moreblocks:coal_glass", 0, true, "Coal Glass")
register_pane("moreblocks", "iron_glass", "moreblocks:iron_glass", 0, true, "Iron Glass")
register_pane("moreblocks", "glow_glass", "moreblocks:glow_glass", 12, true, "Glow Glass")
register_pane("moreblocks", "super_glow_glass", "moreblocks:super_glow_glass", 15, true, "Super Glow Glass")
register_pane("moreblocks", "trap_glass", "moreblocks:trap_glass", 0, false, "Trap Glass")
