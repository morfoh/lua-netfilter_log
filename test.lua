
local nf_log = require"netfilter_log"

-- print packet information
local function print_pkt(ldata)
	io.write("print_pkt(): ")
	io.write("nfmark=", ldata:get_nfmark() .. " ")
	io.write("prefix=", ldata:get_prefix() .. " ")
	io.write("hwtype=", ldata:get_hwtype() .. " ")
	io.write("indev=", ldata:get_indev() .. " ")
	io.write("physindev=", ldata:get_physindev() .. " ")
	io.write("outdev=", ldata:get_outdev() .. " ")
	io.write("physoutdev=", ldata:get_physoutdev() .. " ")
	io.write("hwhdrlen=", ldata:get_msg_packet_hwhdrlen() .. " ")
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

