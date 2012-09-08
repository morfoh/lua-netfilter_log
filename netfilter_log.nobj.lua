
c_module "netfilter_log" {

-- enable FFI bindings support.
luajit_ffi = true,

-- load NETFILTER_LOG shared library.
ffi_load"netfilter_log",

include "netfilter_log.h",

subfiles {
"src/object.nobj.lua",
},
}

