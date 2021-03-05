.PHONY: run
run:
	rm -rf build/
	mkdir -p build/
	cp src/*.lua build/
	cp -r assets/ build/
	cd build/ && love .
