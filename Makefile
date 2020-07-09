.DELETE_ON_ERROR:

FENNEL := vendor/Fennel/fennel
FENNEL_FILES := $(wildcard src/*.fnl)
LUA_FILES := $(FENNEL_FILES:%.fnl=%.lua)
LUA_FILES := $(LUA_FILES:src%=build%)

.PHONY: build
build: init $(LUA_FILES)

.PHONY: init
init:
	mkdir -p build/
	rm -rf build/assets/
	cp -r assets/ build/

build/%.lua: src/%.fnl
	$(FENNEL) --compile $< > $@

.PHONY: clean
clean:
	rm -rf build/

.PHONY: run
run: build
	cd build && exec love .
