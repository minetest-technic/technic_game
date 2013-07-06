local function rotate_rules(node, rules)
	for rotations = 1, node.param2 do
		rules = mesecon:rotate_rules_left(rules)
	end
	return rules
end

local converter_nbx =
{
	type = "fixed",
	fixed = {
		{ -8/16, -8/16, -1/16, 8/16, -7/16, 1/16 },
		{ -3/16, -8/16, -4/16, 3/16, -5/16, 4/16 },
	}
}

local on_digiline_receive = function (pos, node, channel, msg)
	local chan = minetest.get_meta(pos):get_string("channel")
	if channel == chan then
		if node.name == "digilines_converters:d2m_converter_off" and msg == "on" then
			mesecon:swap_node(pos, "digilines_converters:d2m_converter_on")
			mesecon:receptor_on(pos, rotate_rules(node, {{x=1,y=0,z=0}}))
		elseif node.name == "digilines_converters:d2m_converter_on" and msg == "off" then
			mesecon:swap_node(pos, "digilines_converters:d2m_converter_off")
			mesecon:receptor_off(pos, rotate_rules(node, {{x=1,y=0,z=0}}))
		end
	end
end

minetest.register_node("digilines_converters:d2m_converter_off", {
	description = "Digiline to mesecon converter",
	drawtype = "nodebox",
	tiles = {"dc_d2m_off.png", "dc_d2m_off.png", "dc_side_mesecon_off.png", "dc_side_digiline.png", "dc_side_off.png", "dc_side_reverted_off.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {dig_immediate=2, mesecon=2},
	node_box = converter_nbx,
	digiline = 
	{
		effector = {
			rules = function(node)
				return rotate_rules(node, {{x=-1,y=0,z=0}})
			end,
			action = on_digiline_receive
		},
	},
	mesecons =
	{
		receptor = {
			state = "off",
			rules = function(node)
				return rotate_rules(node, {{x=1,y=0,z=0}})
			end,
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.channel = fields.channel or ""
		meta:set_string("channel", fields.channel)
	end,
})

minetest.register_node("digilines_converters:d2m_converter_on", {
	description = "Digiline to mesecon converter on (you hacker you)",
	drawtype = "nodebox",
	drop = "digilines_converters:d2mconverter_off",
	tiles = {"dc_d2m_on.png", "dc_d2m_on.png", "dc_side_mesecon_on.png", "dc_side_digiline.png", "dc_side_on.png", "dc_side_reverted_on.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {dig_immediate=2, mesecon=2, not_in_creative_inventory=1},
	node_box = converter_nbx,
	digiline = 
	{
		effector = {
			rules = function(node)
				return rotate_rules(node, {{x=-1,y=0,z=0}})
			end,
			action = on_digiline_receive
		},
	},
	mesecons =
	{
		receptor = {
			state = "on",
			rules = function(node)
				return rotate_rules(node, {{x=1,y=0,z=0}})
			end,
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.channel = fields.channel or ""
		meta:set_string("channel", fields.channel)
	end,
})

minetest.register_node("digilines_converters:m2d_converter_off", {
	description = "Mesecon to digiline converter",
	drawtype = "nodebox",
	tiles = {"dc_m2d_off.png", "dc_m2d_off.png", "dc_side_mesecon_off.png", "dc_side_digiline.png", "dc_side_off.png", "dc_side_reverted_off.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	groups = {dig_immediate=2, mesecon=2},
	node_box = converter_nbx,
	digiline = 
	{
		receptor =
		{
			rules = function(node)
				return rotate_rules(node, {{x=-1,y=0,z=0}})
			end,
		},
	},
	mesecons =
	{
		effector = {
			rules = function(node)
				return rotate_rules(node, {{x=1,y=0,z=0}})
			end,
			action_on = function(pos, node)
				local c = minetest.get_meta(pos):get_string("channel")
				digiline:receptor_send(pos, rotate_rules(node, {{x=-1,y=0,z=0}}), c, "on")
				mesecon:swap_node(pos, "digilines_converters:m2d_converter_on")
			end,
			action_off = function(pos, node)
				local c = minetest.get_meta(pos):get_string("channel")
				digiline:receptor_send(pos, rotate_rules(node, {{x=-1,y=0,z=0}}), c, "off")
			end,
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.channel = fields.channel or ""
		meta:set_string("channel", fields.channel)
	end,
})

minetest.register_node("digilines_converters:m2d_converter_on", {
	description = "Mesecon to digiline converter on (you hacker you)",
	drawtype = "nodebox",
	tiles = {"dc_m2d_on.png", "dc_m2d_on.png", "dc_side_mesecon_on.png", "dc_side_digiline.png", "dc_side_on.png", "dc_side_reverted_on.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	drop = "digilines_converters:m2d_converter_off",
	groups = {dig_immediate=2, mesecon=2, not_in_creative_inventory=1},
	node_box = converter_nbx,
	digiline = 
	{
		receptor =
		{
			rules = function(node)
				return rotate_rules(node, {{x=-1,y=0,z=0}})
			end,
		},
	},
	mesecons =
	{
		effector = {
			rules = function(node)
				return rotate_rules(node, {{x=1,y=0,z=0}})
			end,
			action_on = function(pos, node)
				local c = minetest.get_meta(pos):get_string("channel")
				digiline:receptor_send(pos, rotate_rules(node, {{x=-1,y=0,z=0}}), c, "on")
			end,
			action_off = function(pos, node)
				local c = minetest.get_meta(pos):get_string("channel")
				digiline:receptor_send(pos, rotate_rules(node, {{x=-1,y=0,z=0}}), c, "off")
				mesecon:swap_node(pos, "digilines_converters:m2d_converter_off")
			end,
		},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", "field[channel;Channel;${channel}]")
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		fields.channel = fields.channel or ""
		meta:set_string("channel", fields.channel)
	end,
})

minetest.register_craft({
	output = 'digilines_converters:d2m_converter_off',
	recipe = {
		{'digilines:wire_std_00000000', 'mesecons_materials:silicon', 'mesecons:mesecon'},
	}
})

minetest.register_craft({
	output = 'digilines_converters:m2d_converter_off',
	recipe = {
		{'mesecons:mesecon', 'mesecons_materials:silicon', 'digilines:wire_std_00000000'},
	}
})
