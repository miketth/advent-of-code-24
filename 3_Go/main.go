package main

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	data, err := os.ReadFile("input.txt")
	if err != nil {
		return fmt.Errorf("read input.txt: %w", err)
	}

	if err := part1(data); err != nil {
		return err
	}

	if err := part2(data); err != nil {
		return err
	}

	return nil
}

func part1(data []byte) error {
	matcher, err := regexp.Compile(`mul\(([0-9]+),([0-9]+)\)`)
	if err != nil {
		return fmt.Errorf("compile regexp: %w", err)
	}

	sum := 0

	matches := matcher.FindAllSubmatch(data, -1)
	for _, match := range matches {
		leftStr, rightStr := match[1], match[2]

		left, err := strconv.Atoi(string(leftStr))
		if err != nil {
			return fmt.Errorf("parse left: %w", err)
		}
		right, err := strconv.Atoi(string(rightStr))
		if err != nil {
			return fmt.Errorf("parse right: %w", err)
		}

		sum += left * right
	}

	fmt.Println(sum)
	return nil
}

func part2(data []byte) error {
	matcher, err := regexp.Compile(`mul\(([0-9]+),([0-9]+)\)|do\(\)|don't\(\)`)
	if err != nil {
		return fmt.Errorf("compile regexp: %w", err)
	}

	sum := 0
	do := true

	matches := matcher.FindAllSubmatch(data, -1)
	for _, match := range matches {
		switch string(match[0]) {
		case "do()":
			do = true
			continue
		case "don't()":
			do = false
			continue
		}

		if !do {
			continue
		}

		leftStr, rightStr := match[1], match[2]

		left, err := strconv.Atoi(string(leftStr))
		if err != nil {
			return fmt.Errorf("parse left: %w", err)
		}
		right, err := strconv.Atoi(string(rightStr))
		if err != nil {
			return fmt.Errorf("parse right: %w", err)
		}

		sum += left * right
	}

	fmt.Println(sum)
	return nil
}
