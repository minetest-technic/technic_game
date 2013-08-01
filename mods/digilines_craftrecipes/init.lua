minetest.register_craft({
	output = 'digilines:wire_std_00000000 4',
	recipe = {
		{'technic:rubber', 'mesecons:mesecon', 'technic:rubber'},
		{'mesecons:mesecon', 'technic:rubber', 'mesecons:mesecon'},
		{'technic:rubber', 'mesecons:mesecon', 'technic:rubber'},
	}
})

minetest.register_craft({
	output = 'digilines_lcd:lcd',
	recipe = {
		{'digilines:wire_std_00000000', 'mesecons_materials:silicon', 'digilines:wire_std_00000000'},
	}
})



minetest.register_craft({
	output = 'digilines_lightsensor:lightsensor',
	recipe = {
		{'digilines:wire_std_00000000', 'technic:brass_ingot', 'digilines:wire_std_00000000'},
	}
})



minetest.register_craft({
	output = 'digilines_lcd:lcd',
	recipe = {
		{'digilines:wire_std_00000000', 'default:bronze_ingot', 'digilines:wire_std_00000000'},
	}
})
