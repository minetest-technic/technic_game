local CYCLES_PER_STEP = 1000
local MAX_CYCLES = 100000
local MAX_LINE_LENGHT = 42

function loadpkg(na)
	local modpath = minetest.get_modpath("forth_computer")
	local ol = package.cpath
	local sp = {modpath.."/?.dll", modpath.."/?.so.32", modpath.."/?.so.64"}
	for i=1,#sp do
		package.cpath = sp[i]
		e, lib = pcall(require, na)
		package.cpath = ol
		if e then
			return lib
		end
	end
	package.cpath = ol
	return nil
end

local modpath = minetest.get_modpath("forth_computer")

local bit32 = loadpkg("bit32")

dofile(modpath.."/computer_memory.lua")

local function s16(x)
	if bit32.band(x, 0x8000)~=0 then
		return bit32.band(x, 0xffff)-0x10000
	end
	return bit32.band(x, 0xffff)
end

local function u16(x)
	return bit32.band(x, 0xffff)
end

local function s32(x)
	if bit32.band(x, 0x80000000)~=0 then
		return bit32.band(x, 0xffffffff)-0x100000000
	end
	return bit32.band(x, 0xffffffff)
end

local function u32(x)
	return bit32.band(x, 0xffffffff)
end

function lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return "" end
	helper((str:gsub("(.-)\r?\n", helper)))
	return t
end

local function hashpos(pos)
	return tostring(pos.x).."\n"..tostring(pos.y).."\n"..tostring(pos.z)
end

local function dehashpos(str)
	local l = lines(str)
	return {x = tonumber(l[1]), y = tonumber(l[2]), z = tonumber(l[3])}
end

local function newline(text, toadd)
	local f = lines(text)
	table.insert(f, toadd)
	return table.concat(f, "\n", 2)
end

local function add_char(text, char)
	local ls = lines(text)
	local ll = ls[#ls]
	if char=="\n" or char=="\r" then
		return newline(text,"")
	elseif string.len(ll)>=MAX_LINE_LENGHT then
		return newline(text, char)
	else
		return text..char
	end
end

local function add_text(text, toadd)
	for i=1, string.len(toadd) do
		text = add_char(text, string.sub(toadd, i, i))
	end
	return text
end

local function readC(cptr, addr)
	return cptr[addr]
end

local function writeC(cptr, addr, value)
	cptr[addr] = bit32.band(value, 0xff)
end

local function read(cptr, addr)
	return cptr[addr] + 256*cptr[u16(addr+1)]
end

local function write(cptr, addr, value)
	cptr[addr] = bit32.band(value, 0xff)
	cptr[addr+1] = bit32.band(value, 0xff00)/256
end

local function push(cptr, value)
	cptr.SP = u16(cptr.SP+2)
	write(cptr, cptr.SP, value)
end

local function pop(cptr, value)
	local n = read(cptr, cptr.SP)
	cptr.SP = u16(cptr.SP-2)
	return n
end

local function rpush(cptr, value)
	cptr.RP = u16(cptr.RP+2)
	write(cptr, cptr.RP, value)
end

local function rpop(cptr, value)
	local n = read(cptr, cptr.RP)
	cptr.RP = u16(cptr.RP-2)
	return n
end

local function emit(pos, c, cptr)
	local s = string.char(bit32.band(c, 0xff))
	local meta = minetest.get_meta(pos)
	local text = meta:get_string("text")
	local ls = lines(text)
	local ll = ls[#ls]
	if s=="\n" or s=="\r" then
		meta:set_string("text", newline(text,""))
	elseif string.len(ll)>=MAX_LINE_LENGHT then
		meta:set_string("text", newline(text, s))
	else
		meta:set_string("text", text..s)
	end
	cptr.fmodif = true
end

local function string_at(cptr, addr, len)
	local l = {}
	for k=1, len do
		local i = u16(addr+k-1)
		local s = cptr[i]
		l[k] = string.char(s)
	end
	return table.concat(l, "")
end

local function receive(cptr, caddr, clen, raddr)
	local channel = string_at(cptr, caddr, clen)
	local event = cptr.digiline_events[channel]
	if event and type(event)=="string" then
		if string.len(event)>80 then
			event = string.sub(event,1,80)
		end
		for i=1,string.len(event) do
			cptr[u16(raddr-1+i)] = string.byte(event,i)
		end
		cptr.X = string.len(event)
	else
		cptr.X = u16(-1)
	end
end

local function delete_message(cptr, caddr, clen)
	local channel = string_at(cptr, caddr, clen)
	cptr.digiline_events[channel] = nil
end

local function set_channel(cptr, caddr, clen)
	local channel = string_at(cptr, caddr, clen)
	cptr.channel = channel
end

local function send_message(pos, cptr, maddr, mlen)
	local msg = string_at(cptr, maddr, mlen)
	cptr.digiline_events[cptr.channel] = msg
	digiline:receptor_send(pos, digiline.rules.default, cptr.channel, msg)
end

local function run_computer(pos,cptr)
	cptr.cycles = math.max(MAX_CYCLES,cptr.cycles+CYCLES_PER_STEP)
	while 1 do
		instr = cptr[cptr.PC]
		local f = ITABLE[instr]
		if f == nil then return end
		--print("Instr: "..tostring(instr).." PC:  "..tostring(cptr.PC).." SP: "..tostring(cptr.SP).." RP: "..tostring(cptr.RP).." X: "..tostring(cptr.X).." Y: "..tostring(cptr.Y).." Z: "..tostring(cptr.Z).." I: "..tostring(cptr.I))
		cptr.PC = bit32.band(cptr.PC+1, 0xffff)
		setfenv(f, {cptr = cptr, pos=pos, emit=emit, receive=receive, delete_message=delete_message, set_channel=set_channel, send_message=send_message, u16=u16, u32=u32, s16=s16, s32=s32, read=read, write=write, readC=readC, writeC=writeC, push=push, pop=pop, rpush=rpush, rpop=rpop, bit32=bit32, math=math})
		f()
		cptr.cycles = cptr.cycles - 1
		if cptr.paused or cptr.cycles == 0 then
			cptr.paused = false
			return
		end
	end
end

local function create_cptr()
	local cptr = create_cptr_memory()
	cptr.X = 0
	cptr.Y = 0
	cptr.Z = 0
	cptr.I = 0
	cptr.PC = 0x400
	cptr.RP = 0x300
	cptr.SP = 0x200
	cptr.paused = false
	cptr.has_input = false
	cptr.digiline_events = {}
	cptr.channel = ""
	cptr.cycles = 0
	return cptr
end

ITABLE_RAW = {
	[0x28] = "cptr.I = rpop(cptr)",
	[0x29] = "cptr.PC = read(cptr, cptr.I); cptr.I = u16(cptr.I+2)",
	[0x2a] = "rpush(cptr, cptr.I); cptr.I = u16(cptr.PC+2); cptr.PC=read(cptr, cptr.PC)",
	[0x2b] = "cptr.X = read(cptr, cptr.I); cptr.I = u16(cptr.I+2)",
	
	[0x08] = "cptr.X = cptr.SP",
	[0x09] = "cptr.X = cptr.RP",
	[0x0a] = "cptr.X = cptr.PC",
	[0x0b] = "cptr.X = cptr.I",
	
	[0x00] = "cptr.paused = true",
	
	[0x01] = "rpush(cptr, cptr.X)",
	[0x02] = "rpush(cptr, cptr.Y)",
	[0x03] = "rpush(cptr, cptr.Z)",
	[0x10] = "cptr.X = read(cptr, cptr.RP)",
	[0x11] = "cptr.X = rpop(cptr)",
	[0x12] = "cptr.Y = rpop(cptr)",
	[0x13] = "cptr.Z = rpop(cptr)",
	
	[0x20] = "write(cptr, cptr.SP, cptr.X)",
	[0x21] = "push(cptr, cptr.X)",
	[0x22] = "push(cptr, cptr.Y)",
	[0x23] = "push(cptr, cptr.Z)",
	[0x30] = "cptr.X = read(cptr, cptr.SP)",
	[0x31] = "cptr.X = pop(cptr)",
	[0x32] = "cptr.Y = pop(cptr)",
	[0x33] = "cptr.Z = pop(cptr)",
	
	[0x04] = "cptr.X = read(cptr, cptr.X)",
	[0x05] = "cptr.X = read(cptr, cptr.Y)",
	[0x06] = "cptr.Y = read(cptr, cptr.X)",
	[0x07] = "cptr.Y = read(cptr, cptr.Y)",
	
	[0x14] = "cptr.X = readC(cptr, cptr.X)",
	[0x15] = "cptr.X = readC(cptr, cptr.Y)",
	[0x16] = "cptr.Y = readC(cptr, cptr.X)",
	[0x17] = "cptr.Y = readC(cptr, cptr.Y)",
	
	[0x25] = "write(cptr, cptr.X, cptr.Y)",
	[0x26] = "write(cptr, cptr.Y, cptr.X)",
	
	[0x35] = "writeC(cptr, cptr.X, cptr.Y)",
	[0x36] = "writeC(cptr, cptr.Y, cptr.X)",
	
	[0x0c] = "n=cptr.X+cptr.Y; cptr.Y = u16(n); cptr.X = u16(math.floor(n/0x10000))",
	[0x0d] = "n=cptr.X-cptr.Y; cptr.Y = u16(n); cptr.X = u16(math.floor(n/0x10000))",
	[0x0e] = "n=cptr.X*cptr.Y; cptr.Y = u16(n); cptr.X = u16(math.floor(n/0x10000))",
	[0x0f] = "n=s16(cptr.X)*s16(cptr.Y); cptr.Y = u16(n); cptr.X = u16(math.floor(n/0x10000))",
	[0x1e] = "n = cptr.X*0x10000+cptr.Y; cptr.Y = u16(math.floor(n/cptr.Z)); cptr.X = u16(math.floor(n/cptr.Z)/0x10000); cptr.Z = u16(n%cptr.Z)",
	[0x1f] = "n = s32(cptr.X*0x10000+cptr.Y); cptr.Y = u16(math.floor(n/s16(cptr.Z))); cptr.X = u16(math.floor(n/s16(cptr.Z))/0x10000); cptr.Z = u16(n%s16(cptr.Z))",
	[0x2c] = "cptr.X = u16(bit32.band(cptr.X, cptr.Y))",
	[0x2d] = "cptr.X = u16(bit32.bor(cptr.X, cptr.Y))",
	[0x2e] = "cptr.X = u16(bit32.bxor(cptr.X, cptr.Y))",
	[0x2f] = "cptr.X = u16(bit32.bnot(cptr.X))",
	[0x3c] = "cptr.X = bit32.rshift(cptr.X, cptr.Y)",
	[0x3d] = "cptr.X = u16(bit32.arshift(s16(cptr.X), cptr.Y))",
	[0x3e] = "n = cptr.X; cptr.X = u16(bit32.lshift(n, cptr.Y)); cptr.Y = u16(bit32.lshift(n, cptr.Y-16))",
	[0x3f] = "cptr.X = u16(bit32.arshift(s16(cptr.X), 15))",
	
	[0x38] = "cptr.PC = u16(cptr.PC+read(cptr, cptr.PC)+2)",
	[0x39] = "if cptr.X~=0 then cptr.PC = u16(cptr.PC+read(cptr, cptr.PC)) end; cptr.PC = u16(cptr.PC+2)",
	[0x3a] = "if cptr.Y~=0 then cptr.PC = u16(cptr.PC+read(cptr, cptr.PC)) end; cptr.PC = u16(cptr.PC+2)",
	[0x3b] = "if cptr.Z~=0 then cptr.PC = u16(cptr.PC+read(cptr, cptr.PC)) end; cptr.PC = u16(cptr.PC+2)",
	
	[0x18] = "cptr.SP = cptr.X",
	[0x19] = "cptr.RP = cptr.X",
	[0x1a] = "cptr.PC = cptr.X",
	[0x1b] = "cptr.I = cptr.X",
	
	[0x40] = "cptr.Z = cptr.X",
	[0x41] = "cptr.Z = cptr.Y",
	[0x42] = "cptr.X = cptr.Z",
	[0x43] = "cptr.Y = cptr.Z",
	[0x44] = "cptr.X = cptr.Y",
	[0x45] = "cptr.Y = cptr.X",
	
	[0x46] = "cptr.X = u16(cptr.X-1)",
	[0x47] = "cptr.Y = u16(cptr.Y-1)",
	[0x48] = "cptr.Z = u16(cptr.Z-1)",
	
	[0x49] = "cptr.X = u16(cptr.X+1)",
	[0x4a] = "cptr.Y = u16(cptr.Y+1)",
	[0x4b] = "cptr.Z = u16(cptr.Z+1)",
	
	[0x4d] = "cptr.X = read(cptr, cptr.PC); cptr.PC = u16(cptr.PC+2)",
	[0x4e] = "cptr.Y = read(cptr, cptr.PC); cptr.PC = u16(cptr.PC+2)",
	[0x4f] = "cptr.Z = read(cptr, cptr.PC); cptr.PC = u16(cptr.PC+2)",
	
	-- [0x50] = "if cptr.has_input then\ncptr.has_input = false\nelse\ncptr.paused = true\ncptr.PC = u16(cptr.PC-1)\nend",
	-- [0x51] = "emit(pos, cptr.X, cptr)",
	[0x52] = "receive(cptr, cptr.X, cptr.Y, cptr.Z)", -- Digiline receive
	[0x53] = "delete_message(cptr, cptr.X, cptr.Y)",
	[0x54] = "send_message(pos, cptr, cptr.X, cptr.Y)", -- Digiline send
	[0x55] = "set_channel(cptr, cptr.X, cptr.Y)", -- Digiline set channel
}

ITABLE = {}

local formspec_close_table = {}
local function on_formspec_close(name, func)
	formspec_close_table[name] = {func=func}
end

minetest.register_globalstep(function(dtime)
	for name, t in pairs(formspec_close_table) do
		local player = minetest.get_player_by_name(name)
		if player == nil then
			t.func()
			formspec_close_table[name] = nil
			return
		end
		local pitch = player:get_look_pitch()
		local yaw = player:get_look_yaw()
		local pos = player:getpos()
		if t.pitch ~= nil then
			if pitch~=t.pitch or yaw~=t.yaw or pos.x~=t.x or pos.y~=t.y or pos.z~=t.z then
				t.func()
				formspec_close_table[name] = nil
				return
			end
		else
			t.pitch = pitch
			t.yaw = yaw
			t.x = pos.x
			t.y = pos.y
			t.z = pos.z
		end
	end
end)


for i, v in pairs(ITABLE_RAW) do
	ITABLE[i] = loadstring(v)
end

local wpath = minetest.get_worldpath()
local function read_file(fn)
	local f = io.open(fn, "r")
	if f==nil then return {} end
	local t = f:read("*all")
	f:close()
	if t=="" or t==nil then return {} end
	return minetest.deserialize(t)
end

local function write_file(fn, tbl)
	local f = io.open(fn, "w")
	f:write(minetest.serialize(tbl))
	f:close()
end

local cptrs = read_file(wpath.."/forth_computers")
local screens = read_file(wpath.."/screens")

local on_computer_digiline_receive = function (pos, node, channel, msg)
	local cptr = cptrs[hashpos(pos)].cptr
	if cptr == nil then return end
	cptr.digiline_events[channel] = msg
end

minetest.register_node("forth_computer:computer",{
	description = "Computer",
	tiles = {"computer.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	digiline = 
	{
		receptor = {},
		effector = {action = on_computer_digiline_receive},
	},
	on_construct = function(pos)
		cptrs[hashpos(pos)] = {pos=pos, cptr=create_cptr()}
	end,
	on_destruct = function(pos)
		cptrs[hashpos(pos)] = nil
	end,
})

local on_screen_digiline_receive = function (pos, node, channel, msg)
	if channel == "screen" then
		local meta = minetest.get_meta(pos)
		local ntext = add_text(meta:get_string("text"), msg)
		meta:set_string("text",ntext)
		screens[hashpos(pos)].fmodif = true
	end
end

minetest.register_node("forth_computer:screen",{
	description = "Screen",
	tiles = {"screen.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	digiline = 
	{
		receptor = {},
		effector = {action = on_screen_digiline_receive},
	},
	on_construct = function(pos)
		local meta=minetest.get_meta(pos)
		meta:set_string("text","\n\n\n\n\n\n\n\n\n\n")
		screens[hashpos(pos)] = {pos=pos, fmodif=false}
	end,
	on_destruct = function(pos)
		screens[hashpos(pos)] = nil
	end,
	on_rightclick = function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		local name = clicker:get_player_name()
		if screens[hashpos(pos)] == nil then
			screens[hashpos(pos)] = {pos=pos, fmodif=false}
		end
		screens[hashpos(pos)].pname = name
		on_formspec_close(name, function()
			local s = screens[hashpos(pos)]
			if s~= nil then s.pname = nil end
		end)
		minetest.show_formspec(name,"screen"..hashpos(pos),create_formspec(meta:get_string("text")))
	end,
})


minetest.register_globalstep(function(dtime)
	for _,i in pairs(cptrs) do
		run_computer(i.pos, i.cptr)
	end
	for _,i in pairs(screens) do
		if i.fmodif then
			i.fmodif=false
			if i.pname~=nil then
				local meta = minetest.get_meta(i.pos)
				minetest.show_formspec(i.pname,"screen"..hashpos(i.pos),create_formspec(meta:get_string("text")))
			end
		end
	end
end)

minetest.register_on_shutdown(function()
	for _,i in pairs(screens) do
		i.fmodif = false
		i.pname = nil
	end
	write_file(wpath.."/forth_computers",cptrs)
	write_file(wpath.."/screens",screens)
end)

function escape(x)
	return string.gsub(string.gsub(string.gsub(x,";","\\;"), "%]", "\\]"), "%[", "\\[")
end

function create_formspec(text)
	local f = lines(text)
	s = "size[5,4.5;"
	i = -0.25
	for _,x in ipairs(f) do
		s = s.."]label[0,"..tostring(i)..";"..escape(x)--minetest.formspec_escape(x)
		i = i+0.3
	end
	s = s.."]field[0.3,"..tostring(i+0.4)..";4.4,1;f;;]"
	return s
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:sub(1,6)~="screen" then return end
	if fields["f"]==nil or fields["f"]=="" then return end
	local pos = dehashpos(formname:sub(7,-1))
	local s = screens[hashpos(pos)]
	if s==nil then return end
	if string.len(fields["f"])>MAX_LINE_LENGHT then
		fields["f"] = string.sub(fields["f"],1,MAX_LINE_LENGHT)
	end
	digiline:receptor_send(pos, digiline.rules.default, "screen", fields["f"])
	local meta = minetest.get_meta(pos)
	--local ntext = newline(meta:get_string("text"),fields["f"])
	--local ntext = meta:get_string("text")..fields["f"]
	local ntext = add_text(meta:get_string("text"), fields["f"])
	meta:set_string("text",ntext)
	minetest.show_formspec(player:get_player_name(),formname,create_formspec(ntext))
end)

