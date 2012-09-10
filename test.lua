
local nf_log = require"netfilter_log"

-- print packet information
local function print_pkt(ldata)
	local indev = nf_log.get_indev(ldata)
	local physindev = nf_log.get_physindev(ldata)
	local outdev = nf_log.get_outdev(ldata)
	local physoutdev = nf_log.get_physoutdev(ldata)
	io.write("print_pkt(): ")
	io.write("indev=", indev .. " ")
	io.write("physindev=", physindev .. " ")
	io.write("outdev=", outdev .. " ")
	io.write("physoutdev=", physoutdev .. " ")
	io.write("\n")
end

-- callback function
local function cb(gh, nfmsg, nfa, data)
	print("nflog_callback():", gh, nfmsg, nfa, data)
	print_pkt(nfa)
	return 0
end

local h = nf_log.nflog();

print("nflog_unbind:",h:unbind_pf(nf_log.AF_INET))

print("nflog_bind:",h:bind_pf(nf_log.AF_INET))

local gh = nf_log.nflog_group(h, 0)
print("gh = ", gh)
local gh100 = nf_log.nflog_group(h, 100)
print("gh100 = ", gh100)

print("nflog_set_mode:",gh:set_mode(nf_log.NFULNL_COPY_PACKET, 0xffff))

local fd = h:fd()
print("fd = ", fd)

print("callback = ", gh:callback_register(cb))

-- main loop
---[[
repeat
 local rc = h:handle_packet()
 print("handle_packet(): rc=", rc)
until rc < 0
--]]

print("nflog_unbind from group 0:",gh:unbind())
print("nflog_unbind from group 100:",gh100:unbind())

print("nflog_closre:", h:close())

