.PHONY: build run

build:
	meson buildDir
	ninja -C buildDir

run: build
	buildDir/src/aoc24
