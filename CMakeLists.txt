#
# Lua bindings for libnetfilter_log
#
cmake_minimum_required(VERSION 2.8)

project(lua-netfilter_log C)

set(BUILD_SHARED_LIBS TRUE)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set(INSTALL_CMOD share/lua/cmod CACHE PATH "Directory to install Lua binary modules (configure lua via LUA_CPATH)")

set(COMMON_CFLAGS "${CFLAGS}")
set(COMMON_LDFLAGS)
set(COMMON_LIBS)

## Lua 5.1.x
include(FindLua51)
if(NOT ${LUA51_FOUND})
    message(FATAL_ERROR "The FindLua51 module could not find lua :-(")
endif()
set(COMMON_LIBS "${COMMON_LIBS};${LUA_LIBRARIES}")

## LibNetfilter_log
include(FindPkgConfig)
pkg_search_module(NETFILTER_LOG REQUIRED libnetfilter_log)
set(COMMON_CFLAGS "${COMMON_CFLAGS} ${NETFILTER_LOG_CFLAGS}")
set(COMMON_LDFLAGS "${COMMON_LDFLAGS} ${NETFILTER_LOG_LDFLAGS}")
set(COMMON_LIBS "${COMMON_LIBS};${NETFILTER_LOG_LIBRARIES}")

## LuaNativeObjects
include(LuaNativeObjects)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_BINARY_DIR}
                    ${LUA_INCLUDE_DIR})

## LuaNetfilter_log
set(LUA_NETFILTER_LOG_SRC
	netfilter_log.nobj.lua
)

if(${USE_PRE_GENERATED_BINDINGS})
	set(LUA_NETFILTER_LOG_SRC src/pre_generated-netfilter_log.nobj.c)
else()
	# Generate Lua bindings.
	GenLuaNativeObjects(LUA_NETFILTER_LOG_SRC)
endif()

add_library(lua-netfilter_log MODULE ${LUA_NETFILTER_LOG_SRC})
target_link_libraries(lua-netfilter_log ${COMMON_LIBS})
set_target_properties(lua-netfilter_log PROPERTIES PREFIX "")
set_target_properties(lua-netfilter_log PROPERTIES COMPILE_FLAGS "${COMMON_CFLAGS}")
set_target_properties(lua-netfilter_log PROPERTIES OUTPUT_NAME netfilter_log)

install(TARGETS lua-netfilter_log
        DESTINATION "${INSTALL_CMOD}")

