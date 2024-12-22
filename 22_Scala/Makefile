.PHONY: build run run-sbt

build:
	sbt package

run-sbt:
	sbt run

run: build
	scala -cp target/scala-3.3.4/22_scala_3-0.1.0-SNAPSHOT.jar main
