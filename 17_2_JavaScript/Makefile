.PHONY: run build run-deno

run-deno:
	deno run --allow-read=input.txt main.js

build:
	deno compile -o main --allow-read=input.txt main.js

run: build
	./main

