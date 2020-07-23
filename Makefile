.DELETE_ON_ERROR:

FENNEL = vendor/Fennel/fennel
# FENNEL_FILES = $(wildcard src/*.fnl)

# src/%.lua: src/%.fnl
# 	vendor/Fennel/fennel --compile $< > $@

.PHONY: build
build: src/*.fnl
	mkdir -p build/
	$(FENNEL) --compile src/main.fnl > build/main.lua
	$(FENNEL) --compile src/conf.fnl > build/conf.lua
	$(FENNEL) --compile src/map.fnl > build/map.lua
	$(FENNEL) --compile src/colors.fnl > build/colors.lua
	$(FENNEL) --compile src/utils.fnl > build/utils.lua
	$(FENNEL) --compile src/frames-graph-view.fnl > build/frames-graph-view.lua
	$(FENNEL) --compile src/dungeon-generator.fnl > build/dungeon-generator.lua
	$(FENNEL) --compile src/tile.fnl > build/tile.lua
	$(FENNEL) --compile src/tile-kind.fnl > build/tile-kind.lua
	$(FENNEL) --compile src/random.fnl > build/random.lua
	$(FENNEL) --compile src/tileset.fnl > build/tileset.lua
	$(FENNEL) --compile src/player-input.fnl > build/player-input.lua
	$(FENNEL) --compile src/enum.fnl > build/enum.lua
	$(FENNEL) --compile src/shortest-path.fnl > build/shortest-path.lua
	$(FENNEL) --compile src/two-d-array.fnl > build/two-d-array.lua
	$(FENNEL) --compile src/hash-set.fnl > build/hash-set.lua
	$(FENNEL) --compile src/unit.fnl > build/unit.lua
	$(FENNEL) --compile src/fov-state.fnl > build/fov-state.lua
	$(FENNEL) --compile src/tile-content-view.fnl > build/tile-content-view.lua
	$(FENNEL) --compile src/inventory.fnl > build/inventory.lua
	$(FENNEL) --compile src/wand.fnl > build/wand.lua
	$(FENNEL) --compile src/event-handlers.fnl > build/event-handlers.lua
	$(FENNEL) --compile src/wand-activation-event-handler.fnl > build/wand-activation-event-handler.lua
	cp -r assets/ build/

.PHONY: clean
clean:
	rm -rf build/

.PHONY: run
run: build
	cd build && exec love .
