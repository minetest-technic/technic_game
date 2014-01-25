
-------------------------
-- Make lava renewable --
-------------------------

minetest.registered_nodes["default:lava_source"].liquid_renewable = true
minetest.registered_nodes["default:lava_flowing"].liquid_renewable = true

minetest.register_node(":default:lava_source", minetest.registered_nodes["default:lava_source"])
minetest.register_node(":default:lava_flowing", minetest.registered_nodes["default:lava_flowing"])

----------------------------------------------------
-- Only cool lava that is actually touching water --
----------------------------------------------------

local function check_nearby_nodes(pos, nodename)
	if minetest.get_node({x=pos.x+1, y=pos.y,   z=pos.z  }).name == nodename or
	   minetest.get_node({x=pos.x-1, y=pos.y,   z=pos.z  }).name == nodename or
	   minetest.get_node({x=pos.x,   y=pos.y+1, z=pos.z  }).name == nodename or
	   minetest.get_node({x=pos.x,   y=pos.y-1, z=pos.z  }).name == nodename or
	   minetest.get_node({x=pos.x,   y=pos.y,   z=pos.z+1}).name == nodename or
	   minetest.get_node({x=pos.x,   y=pos.y,   z=pos.z-1}).name == nodename then
		return true
	end
end


local old_cool_lava_source = default.cool_lava_source
function default.cool_lava_source(pos)
	if check_nearby_nodes(pos, "default:water_source") or
	   check_nearby_nodes(pos, "default:water_flowing") then
		old_cool_lava_source(pos)
	end
end


local old_cool_lava_flowing = default.cool_lava_flowing
function default.cool_lava_flowing(pos)
	if check_nearby_nodes(pos, "default:water_source") or
	   check_nearby_nodes(pos, "default:water_flowing") then
		old_cool_lava_flowing(pos)
	end
end

------------------------------------
-- Add backgrounds to wood chests --
------------------------------------


default.chest_formspec = default.chest_formspec
	.."label[0,0;Wooden Chest]"
	.."background[-0.19,-0.25;8.4,10.75;ui_form_bg.png]"
	.."background[0,1;8,4;ui_wooden_chest_inventory.png]"
	.."background[0,6;8,4;ui_main_inventory.png]"

local old_get_locked_chest_formspec = default.get_locked_chect_formspec
function default.get_locked_chest_formspec(...)
	return old_get_locked_chest_formspec(...)
		.."label[0,0;Wooden Locked Chest]"
		.."background[-0.19,-0.25;8.4,10.75;ui_form_bg.png]"
		.."background[0,1;8,4;ui_wooden_chest_inventory.png]"
		.."background[0,6;8,4;ui_main_inventory.png]"
end

-----------------------
-- Same for furnaces --
-----------------------

default.furnace_inactive_formspec = default.furnace_inactive_formspec
	.."label[0,0;Furnace]"
	.."background[-0.19,-0.25;8.4,10.75;ui_form_bg.png]"
	.."background[0,6;8,4;ui_main_inventory.png]"
	.."background[0,1;8,4;ui_furnace_inventory.png]"

local old_get_furnace_active_formspec = default.get_furnace_active_formspec
function default.get_furnace_active_formspec(...)
	return old_get_furnace_active_formspec(...)
		.."label[0,0;Furnace Active]"
		.."background[-0.19,-0.25;8.4,10.75;ui_form_bg.png]"
		.."background[0,6;8,4;ui_main_inventory.png]"
		.."background[0,1;8,4;ui_furnace_inventory.png]"
end

