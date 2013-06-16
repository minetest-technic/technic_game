-- Global configuration variables

-- Enable the various kinds of trees.

moretrees.enable_apple_tree	= true
moretrees.enable_oak		= true
moretrees.enable_sequoia	= true
moretrees.enable_palm		= true
moretrees.enable_pine		= true
moretrees.enable_rubber_tree	= true
moretrees.enable_willow		= true
moretrees.enable_birch		= true
moretrees.enable_spruce		= true
moretrees.enable_jungle_tree	= true
moretrees.enable_fir		= true
moretrees.enable_beech		= false

-- Set this to true to enable leaf decay of all trees except the default ones.

moretrees.enable_leafdecay = true

-- Enable this one if you want this mod's leafdecay code to affect the old
-- default trees too; this setting is independent of the one above.  You'll
-- want to manually disable the default leafdecay code in minetest_game if
-- you enable this, otherwise you'll have two sets of leaf decay code running
-- at the same time, which will just waste CPU for no benefit.

moretrees.enable_default_leafdecay = true

-- Enable this if you want moretrees to redefine default apples so that they
-- fall when leaves decay/are dug.

moretrees.enable_redefine_apple = true

-- various settings to configure leaf decay in general.

moretrees.leafdecay_delay = 2
moretrees.leafdecay_chance = 200
moretrees.leafdecay_radius = 5

moretrees.palm_leafdecay_radius = 12

moretrees.default_leafdecay_delay = 3
moretrees.default_leafdecay_chance = 100
moretrees.default_leafdecay_radius = 4

-- Change these settings if you want default trees to be gradually cut down
-- above the elevation where firs normally generate.

moretrees.firs_remove_default_trees = false
moretrees.firs_remove_interval = 2
moretrees.firs_remove_chance = 150

-- Sapling settings

moretrees.sapling_interval = 500
moretrees.sapling_chance = 20
