module main

import os

// const input_file = 'input_sample.txt'
// const input_file = 'input_sample_larger.txt'
const input_file = 'input.txt'

fn main() {
	warehouse := read_file(input_file)!
	end_warehouse := do_instructions(warehouse)
	print_map(end_warehouse)
	mut result := 0
	for y, line in end_warehouse.fields {
		for x, item in line {
			if item == .box {
				result += (100 * y) + x
			}
		}
	}
	println('${result}')
}

fn do_instructions(warehouse Warehouse) Warehouse {
	mut fields := warehouse.fields.clone()
	mut robot_pos := warehouse.robot_pos
	for instruction in warehouse.instructions {
		next := robot_pos.next(instruction)
		success := move(mut fields, next, instruction)
		if success {
			robot_pos = next
		}
	}

	return Warehouse{
		robot_pos:    robot_pos
		fields:       fields
		instructions: []
	}
}

fn move(mut fields Fields, coord Coord, direction Instruction) bool {
	item := fields[coord.y][coord.x]
	if item == .nothing {
		return true
	}
	if item == .wall {
		return false
	}

	next := coord.next(direction)

	success := move(mut fields, next, direction)
	if !success {
		return false
	}

	fields[next.y][next.x] = item
	fields[coord.y][coord.x] = .nothing
	return true
}

struct Coord {
	x int
	y int
}

fn (c Coord) next(i Instruction) Coord {
	next_x := match i {
		.up, .down { c.x }
		.left { c.x - 1 }
		.right { c.x + 1 }
	}
	next_y := match i {
		.left, .right { c.y }
		.up { c.y - 1 }
		.down { c.y + 1 }
	}

	return Coord{
		x: next_x
		y: next_y
	}
}

enum MapElement {
	box
	wall
	nothing
}

enum Instruction {
	up
	down
	left
	right
}

type Fields = map[int]map[int]MapElement

struct Warehouse {
	robot_pos    Coord
	fields       Fields = map[int]map[int]MapElement{}
	instructions []Instruction
}

fn read_file(name string) !Warehouse {
	mut robot_pos := Coord{}
	mut fields := map[int]map[int]MapElement{}

	data := os.read_file(name)!
	data_parts := data.split('\n\n')
	warehouse_str, instructions_str := data_parts[0], data_parts[1]

	for y, line in warehouse_str.split('\n') {
		mut this_line := map[int]MapElement{}
		for x, field in line {
			this_line[x] = match field {
				`#` {
					MapElement.wall
				}
				`O` {
					MapElement.box
				}
				`.` {
					MapElement.nothing
				}
				`@` {
					robot_pos = Coord{
						x: x
						y: y
					}
					MapElement.nothing
				}
				else {
					return error('unknown cell: ${field.str()}')
				}
			}
		}
		fields[y] = this_line.move()
	}

	instructions := instructions_str.runes().filter(it != `\n`).map(match it {
		`^` { Instruction.up }
		`>` { Instruction.right }
		`v` { Instruction.down }
		`<` { Instruction.left }
		else { return error('unknown instruction: ${it.str()}') }
	})

	return Warehouse{
		robot_pos:    robot_pos
		fields:       fields
		instructions: instructions
	}
}

fn print_map(warehouse Warehouse) {
	for y in 0 .. warehouse.fields.len {
		line := warehouse.fields[y].clone()
		for x in 0 .. line.len {
			elem := line[x]

			this_coord := Coord{
				x: x
				y: y
			}
			if this_coord == warehouse.robot_pos {
				print('@')
			} else {
				print(match elem {
					.box { 'O' }
					.wall { '#' }
					.nothing { '.' }
				})
			}
		}
		println('')
	}
}
