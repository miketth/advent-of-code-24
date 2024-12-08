.PHONY: build run-mix run

build:
	MIX_ENV=prod mix release --overwrite

run-mix:
	mix run

run: build
	_build/prod/rel/aoc24/bin/aoc24 start

