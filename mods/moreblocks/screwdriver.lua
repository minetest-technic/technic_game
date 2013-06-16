-- Load translation library if intllib is installed

local S
if (minetest.get_modpath("intllib")) then
	dofile(minetest.get_modpath("intllib").."/intllib.lua")
	S = intllib.Getter(minetest.get_current_modname())
	else
	S = function ( s ) return s end
end

-- Thanks to RealBadAngel for the screwdriver

minetest.register_tool("moreblocks:screwdriver", {
	description = S("Screwdriver"),
	inventory_image = "moreblocks_screwdriver.png",
	wield_image = "moreblocks_screwdriver.png^[transformR90",
	on_use = function(itemstack, user, pointed_thing)
		-- Must be pointing to facedir applicable node
		if pointed_thing.type~="node" then return end
		local pos=minetest.get_pointed_thing_position(pointed_thing,above)
		local node=minetest.env:get_node(pos)
		local node_name=node.name
			if minetest.registered_nodes[node_name].paramtype2 == "facedir" or minetest.registered_nodes[node_name].paramtype2 == "wallmounted" then
		if node.param2==nil  then return end
		-- Get ready to set the param2
		local n = node.param2
							if minetest.registered_nodes[node_name].paramtype2 == "facedir" then
		n = n+1
		if n == 4 then n = 0 end
							else
							n = n+1
							if n == 6 then n = 0 end
							end
		local meta = minetest.env:get_meta(pos)
		local meta0 = meta:to_table()
		node.param2 = n
		minetest.env:set_node(pos,node)
		meta = minetest.env:get_meta(pos)
		meta:from_table(meta0)
		local item=itemstack:to_table()
		local item_wear=tonumber((item["wear"]))
		item_wear=item_wear+819
		if item_wear>65535 then itemstack:clear() return itemstack end
		item["wear"]=tostring(item_wear)
		itemstack:replace(item)
		return itemstack
			else
			return itemstack
			end
	end,
	on_rightclick = function(itemstack, user, pointed_thing)
		-- Must be pointing to facedir applicable node
		if pointed_thing.type~="node" then return end
		local pos=minetest.get_pointed_thing_position(pointed_thing,above)
		local node=minetest.env:get_node(pos)
		local node_name=node.name
			if minetest.registered_nodes[node_name].paramtype2 == "facedir" or minetest.registered_nodes[node_name].paramtype2 == "wallmounted" then
		if node.param2==nil  then return end
		-- Get ready to set the param2
		local n = node.param2
							if minetest.registered_nodes[node_name].paramtype2 == "facedir" then
		n = n-1
		if n == 0 then n = 4 end
							else
							n = n-1
							if n == 0 then n = 6 end
							end
		local meta = minetest.env:get_meta(pos)
		local meta0 = meta:to_table()
		node.param2 = n
		minetest.env:set_node(pos,node)
		meta = minetest.env:get_meta(pos)
		meta:from_table(meta0)
		local item=itemstack:to_table()
		local item_wear=tonumber((item["wear"]))
		item_wear=item_wear+819
		if item_wear>65535 then itemstack:clear() return itemstack end
		item["wear"]=tostring(item_wear)
		itemstack:replace(item)
		return itemstack
			else
			return itemstack
			end
	end,
})

minetest.register_craft({
	output = "moreblocks:screwdriver",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:stick"},
	}
})

minetest.register_craft({
	output = "moreblocks:screwdriver",
	recipe = {
		{"default:stick", "default:steel_ingot", "default:steel_ingot"},
	}
})
