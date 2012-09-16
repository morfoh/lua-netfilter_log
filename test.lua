
local nf_log = require"netfilter_log"

-- print packet information
local function print_pkt(ldata)
	io.write("print_pkt(): ")
	-- timestamp
	local tssec, tsusec = ldata:get_timestamp()
	if tssec and tsusec then
		io.write("timestamp=" .. tssec .."." .. tsusec .. " ")
	end
	local seq_global = ldata:get_seq_global()
	if seq_global then
		io.write("seq_global=" .. seq_global .. " ")
	end
	local seq = ldata:get_seq()
	if seq then
		io.write("seq=" .. seq .. " ")
	end
	io.write("nfmark=", ldata:get_nfmark() .. " ")
	io.write("prefix=", ldata:get_prefix() .. " ")
	io.write("hwtype=", ldata:get_hwtype() .. " ")
	io.write("indev=", ldata:get_indev() .. " ")
	io.write("physindev=", ldata:get_physindev() .. " ")
	io.write("outdev=", ldata:get_outdev() .. " ")
	io.write("physoutdev=", ldata:get_physoutdev() .. " ")
	io.write("hwhdrlen=", ldata:get_msg_packet_hwhdrlen() .. " ")
	local uid = ldata:get_uid()
	if uid then
		io.write("uid=" .. uid .. " ")
	end
	local gid = ldata:get_gid()
	if gid then
		io.write("gid=" .. gid .. " ")
	end
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

local gh0 = nf_log.nflog_group(h, 0)
print("gh0 = ", gh0)
local gh1 = nf_log.nflog_group(h, 1)
print("gh1 = ", gh1)

print("gh0:nflog_set_mode:",gh0:set_mode(nf_log.NFULNL_COPY_PACKET, 0xffff))
print("gh1:nflog_set_mode:",gh1:set_mode(nf_log.NFULNL_COPY_PACKET, 0xffff))
print("enable local and global sequence numbering")
print("nflog_set_flags:",gh0:set_flags(nf_log.NFULNL_CFG_F_SEQ + nf_log.NFULNL_CFG_F_SEQ_GLOBAL))
print("nflog_set_flags:",gh1:set_flags(nf_log.NFULNL_CFG_F_SEQ + nf_log.NFULNL_CFG_F_SEQ_GLOBAL))

local fd = h:fd()
print("fd = ", fd)

print("gh0:callback = ", gh0:callback_register(cb))
print("gh1:callback = ", gh1:callback_register(cb))

-- main loop
---[[
repeat
 local rc = h:handle_packet()
 print("handle_packet(): rc=", rc)
until rc < 0
--]]

print("nflog_unbind from group 0:",gh0:unbind())
print("nflog_unbind from group 1:",gh1:unbind())

print("nflog_close:", h:close())

