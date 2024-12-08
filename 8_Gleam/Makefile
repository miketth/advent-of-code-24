.PHONY: build run-gleam run-gleam-js run build-js run-js

JS=deno
JS_FLAGS=--allow-read

build:
	gleam export erlang-shipment

run-gleam:
	gleam run -t erlang

run-gleam-js:
	gleam run -t javascript --runtime $(JS)

run: build
	build/erlang-shipment/entrypoint.sh run

build-js:
	gleam build -t javascript

run-js: build-js
	$(JS) $(JS_FLAGS) build/dev/javascript/aoc24/gleam.main.mjs
