.PHONY: build run

build:
	mkdir -p build
	cmake -S . -B build
	$(MAKE) -C build all

run: build
	build/21_CPP
