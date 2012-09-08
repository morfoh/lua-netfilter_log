#!/usr/bin/env lua

package	= 'lua-netfilter_log'
version	= 'scm-0'
source	= {
	url	= 'https://github.com/morfoh/lua-netfilter_log'
}
description	= {
	summary	= "Lua bindings for libnetfilter_log.",
	detailed	= '',
	homepage	= 'https://github.com/morfoh/lua-netfilter_log',
	license	= 'MIT',
	maintainer = "Christian Wiese",
}
dependencies = {
	'lua >= 5.1',
}
external_dependencies = {
	NETFILTER_LOG = {
		header = "netfilter_log.h",
		library = "netfilter_log",
	}
}
build	= {
	type = "builtin",
	modules = {
		netfilter_log = {
			sources = { "src/pre_generated-netfilter_log.nobj.c" },
			libraries = { "netfilter_log" },
		}
	}
}
