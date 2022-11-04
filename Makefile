LUA ?= lua5.1
LUA_VERSION = $(shell $(LUA) -e 'print(_VERSION:match("%d%.%d"))')
LUAROCKS = luarocks --lua-version=$(LUA_VERSION)
LUA_PATH_MAKE = $(shell $(LUAROCKS) path --lr-path);./?.lua;./?/init.lua
LUA_CPATH_MAKE = $(shell $(LUAROCKS) path --lr-cpath);./?.so

.PHONY: test local build watch lint count show

build:
	LUA_PATH='$(LUA_PATH_MAKE)' LUA_CPATH='$(LUA_CPATH_MAKE)' $(LUA) bin/moonc moon/ moonscript/
	echo "#!/usr/bin/env lua" > bin/moon
	$(LUA) bin/moonc -p bin/moon.moon >> bin/moon
	echo "-- vim: set filetype=lua:" >> bin/moon

show:
	# LUA $(LUA)
	# LUA_VERSION $(LUA_VERSION)
	# LUAROCKS $(LUAROCKS)
	# LUA_PATH_MAKE $(LUA_PATH_MAKE)
	# LUA_CPATH_MAKE $(LUA_CPATH_MAKE)

test: build
	busted

local: build
	LUA_PATH='$(LUA_PATH_MAKE)' LUA_CPATH='$(LUA_CPATH_MAKE)' $(LUAROCKS) make --local moonscript-dev-1.rockspec

watch:
	moonc moon/ moonscript/ && moonc -w moon/ moonscript/

lint:
	moonc -l moonscript moon bin

count:
	wc -l $$(git ls-files | grep 'moon$$') | sort -n | tail
