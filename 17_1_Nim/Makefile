.PHONY: run run-nim build

run-nim:
	nim r main.nim

build:
	nim c -d:release main.nim

run: build
	./main

