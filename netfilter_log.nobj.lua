-- make generated variable nicer
set_variable_format "%s"

c_module "netfilter_log" {

-- enable FFI bindings support.
luajit_ffi = true,

-- load NETFILTER_LOG shared library.
ffi_load"netfilter_log",

sys_include "sys/types.h",
sys_include "unistd.h",
sys_include "netdb.h",
sys_include "libnetfilter_log/libnetfilter_log.h",

subfiles {
"src/nflog.nobj.lua",
},
}

