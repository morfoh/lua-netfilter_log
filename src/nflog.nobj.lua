-- Copyright (c) 2012 by Christian Wiese <chris@opensde.org>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

basetype "nfgenmsg *"		"lightuserdata" "NULL"

-- typedefs
local typedefs = [[
typedef struct nflog_handle nflog;
typedef struct nflog_g_handle nflog_group;
typedef struct nfgenmsg nfgenmsg;
typedef struct nflog_data nflog_data;
typedef struct nfulnl_msg_packet_hw nfulnl_msg_packet_hw;
]]
c_source "typedefs" (typedefs)
-- pass extra C type info to FFI.
ffi_cdef (typedefs)

export_definitions {
-- address families
"AF_UNSPEC",
"AF_UNIX",
"AF_INET",
"AF_INET6",
"AF_IPX",
"AF_NETLINK",
"AF_PACKET",

"NFULNL_COPY_NONE",
"NFULNL_COPY_META",
"NFULNL_COPY_PACKET",
}

--
-- nflog handle
--
object "nflog" {
	-- The first constructor can be called as: netfilter_log.nflog() or netfilter_log.nflog.new()
	-- The default name for a constructor is 'new'
	constructor {
		c_call "nflog *" "nflog_open" {}
	},
	-- "close" destructor allows freeing of the object before it gets GC'ed
	destructor "close" {
		c_method_call "int" "nflog_close" {}
	},

	method "bind_pf" {
		c_method_call "int" "nflog_bind_pf" { "uint16_t", "pf" }
	},

	method "unbind_pf" {
		c_method_call "int" "nflog_unbind_pf" { "uint16_t", "pf" }
	},

	method "fd" {
		c_method_call "int" "nflog_fd" {}
	},
	method "handle_packet" {
		var_out{ "int", "rc" },
		c_source[[
#define BUF_LEN 4096
  int fd = nflog_fd(${this});
  char buf[BUF_LEN];

  ${rc} = recv(fd, buf, sizeof(buf), 0);
  if(${rc} >= 0) {
    ${rc} = nflog_handle_packet(${this}, buf, ${rc});
  }
]],
	},
}

-- nflog callback type
callback_type "NFLogFunc" "int"
	{ "nflog_group *", "gh", "nfgenmsg *", "nfmsg", "nflog_data *", "nfd", "void *", "%data" }

--
-- nflog group handle
--
object "nflog_group" {
	-- The first constructor can be called as: netfilter_log.nflog_group() or netfilter_log.nflog_group.new()
	-- The default name for a constructor is 'new'
	constructor {
		c_call "nflog_group *" "nflog_bind_group" { "nflog *", "nflog_handle", "uint16_t", "num"}
	},
	-- "unbind" destructor allows freeing of the object before it gets GC'ed
	destructor "unbind" {
		c_method_call "int" "nflog_unbind_group" {}
	},

	method "set_mode" {
		c_method_call "int" "nflog_set_mode" { "uint8_t", "mode", "uint32_t", "range" }
	},

	method "set_timeout" {
		c_method_call "int" "nflog_set_timeout" { "uint32_t", "timeout" }
	},

	method "set_qtresh" {
		c_method_call "int" "nflog_set_qthresh" { "uint32_t", "qthresh" }
	},

	method "set_nlbufsiz" {
		c_method_call "int" "nflog_set_nlbufsiz" { "uint32_t", "nlbufsiz" }
	},

	method "set_flags" {
		c_method_call "int" "nflog_set_flags" { "uint16_t", "flags" }
	},
	method "callback_register" {
		callback { "NFLogFunc", "func", "func_data", owner = "this",
			-- code to run if Lua callback function throws an error.
			c_source[[${ret} = -1;]],
			ffi_source[[${ret} = -1;]],
		},
		c_method_call "int" "nflog_callback_register" { "NFLogFunc", "func", "void *", "func_data" },
	},
}

--
-- nflog_data
--
object "nflog_data" {
	-- get the hardware link layer type from logging data
	method "get_hwtype" {
		c_method_call "uint16_t" "nflog_get_hwtype" {}
	},
	-- get the length of the hardware link layer header
	method "get_msg_packet_hwhdrlen" {
		c_method_call "uint16_t" "nflog_get_msg_packet_hwhdrlen" {}
	},
	-- get the packet mark
	method "get_nfmark" {
		c_method_call "uint32_t" "nflog_get_nfmark" {}
	},
	-- get the interface that the packet was received through
	method "get_indev" {
		c_method_call "uint32_t" "nflog_get_indev" {}
	},
	-- get the physical interface that the packet was received
	method "get_physindev" {
		c_method_call "uint32_t" "nflog_get_physindev" {}
	},
	-- gets the interface that the packet will be routed out
	method "get_outdev" {
		c_method_call "uint32_t" "nflog_get_outdev" {}
	},
	-- get the physical interface that the packet output
	method "get_physoutdev" {
		c_method_call "uint32_t" "nflog_get_physoutdev" {}
	},
	-- get the logging string prefix
	method "get_prefix" {
		c_method_call "char *" "nflog_get_prefix" {}
	},
	-- get the UID of the user that has generated the packet
	method "get_uid" {
		var_out { "uint32_t", "uid" },
		c_source "pre_src" [[
  int rc;
]],
		c_source [[
  rc = nflog_get_uid(this, &uid);

  /* return nil when there is no uid attribute available */
  if (rc == -1) {
	lua_pushnil(L);
	return 1;
  }
]],
	},
	-- get the GID of the user that has generated the packet
	method "get_gid" {
		var_out { "uint32_t", "gid" },
		c_source "pre_src" [[
  int rc;
]],
		c_source [[
  rc = nflog_get_gid(this, &gid);

  /* return nil when there is no gid attribute available */
  if (rc == -1) {
	lua_pushnil(L);
	return 1;
  }
]],
	},
}

--
-- nfulnl_msg_packet_hw
--
object "nfulnl_msg_packet_hw" {
}
