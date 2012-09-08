#!/usr/bin/env lua

package	= 'lua-netfilter_log'
version	= 'scm-0'
source	= {
	url	= '__project_git_url__'
}
description	= {
	summary	= "LuaNativeObjects project template.",
	detailed	= '',
	homepage	= '__project_homepage__',
	license	= 'MIT',
	maintainer = "christian wiese",
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
