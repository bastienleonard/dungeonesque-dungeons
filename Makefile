.DELETE_ON_ERROR:

FENNEL := vendor/Fennel/fennel
FENNEL_FILES := $(wildcard src/*.fnl)
LUA_FILES := $(FENNEL_FILES:%.fnl=%.lua)
LUA_FILES := $(LUA_FILES:src%=build%)
FENNEL_TEST_FILES := $(wildcard tests/*.fnl)
LUA_TEST_FILES := $(FENNEL_TEST_FILES:%.fnl=%.lua)
LUA_TEST_FILES := $(LUA_TEST_FILES:tests%=tests-build%)
LOVE2D_URL := https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip
VERSION := $(shell git tag --list | tail -n 1)
RELEASE_NAME := dungeonesque-dungeons-$(VERSION)
RELEASE_NAME_ALL_PLATFORMS := $(RELEASE_NAME)-allplatforms
RELEASE_NAME_WINDOWS := $(RELEASE_NAME)-windows

.PHONY: build
build: init $(LUA_FILES)

.PHONY: init
init:
	mkdir -p build/
	rm -rf build/assets/
	cp -r assets/ build/

build/%.lua: src/%.fnl
	$(FENNEL) --compile --add-fennel-path src/macros/?.fnl $< > $@

.PHONY: run
run: build
	cd build && exec love .

.PHONY: test
test: build test-init $(LUA_TEST_FILES)
	mv tests-build/main.lua tests-build/main.lua.bak
	cp build/*.lua tests-build/
	mv tests-build/main.lua.bak tests-build/main.lua
	cd tests-build/ && love .

tests-build/%.lua: tests/%.fnl
	$(FENNEL) --compile $< > $@

.PHONY: test-init
test-init:
	mkdir -p tests-build/

.PHONY: dist
dist: build
	mkdir -p dist/
	mkdir dist/$(RELEASE_NAME)-allplatforms/
	cd build &&\
zip -9 --no-dir-entries -r ../dist/$(RELEASE_NAME_ALL_PLATFORMS)/$(RELEASE_NAME).love .
	cp README.md LICENSE.txt dist/$(RELEASE_NAME)-allplatforms
	cd dist/ &&\
zip -9 -r $(RELEASE_NAME)-allplatforms.zip $(RELEASE_NAME_ALL_PLATFORMS)
	wget $(LOVE2D_URL) -O dist/love2d.zip
	cd dist/ && unzip love2d.zip
	mkdir dist/$(RELEASE_NAME_WINDOWS)/
	cp dist/love*/*.dll dist/$(RELEASE_NAME_WINDOWS)/
	cp dist/love*/license.txt \
dist/$(RELEASE_NAME_WINDOWS)/love2d-license.txt
	cat dist/love*/love.exe dist/$(RELEASE_NAME_ALL_PLATFORMS)/$(RELEASE_NAME).love > \
dist/$(RELEASE_NAME_WINDOWS)/$(RELEASE_NAME).exe
	cd dist/ &&\
zip -9 -r $(RELEASE_NAME_WINDOWS).zip $(RELEASE_NAME_WINDOWS)

.PHONY: clean
clean:
	rm -rf build/
	rm -rf tests-build/
	rm -rf dist/
