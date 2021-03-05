# Copyright 2021 Bastien Léonard

# This file is part of Dungeonesque Dungeons.

# Dungeonesque Dungeons is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.

# Dungeonesque Dungeons is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.

# You should have received a copy of the GNU General Public License along with
# Dungeonesque Dungeons. If not, see <https://www.gnu.org/licenses/>.

SHELL := /bin/bash -O globstar

LOVE2D_URL := https://github.com/love2d/love/releases/download/11.3/love-11.3-win32.zip
VERSION := $(shell git tag --list | tail -n 1)
# TODO
VERSION := WIP
RELEASE_NAME := dungeonesque-dungeons-$(VERSION)
RELEASE_NAME_ALL_PLATFORMS := $(RELEASE_NAME)-allplatforms
RELEASE_NAME_WINDOWS := $(RELEASE_NAME)-windows


.DELETE_ON_ERROR:

.PHONY: build
build:
	mkdir -p build/
	cd src/ && cp --parents **/*.lua ../build/
	cp -r assets/ build/

.PHONY: run
run: build
	cd build/ && love .

.PHONY: run_wine
run_wine: dist
	wine dist/$(RELEASE_NAME_WINDOWS)/$(RELEASE_NAME).exe

.PHONY: clean
clean:
	rm -rf build/ dist/

.PHONY: dist
dist: clean build
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
