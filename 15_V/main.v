module main

import os
import term
import time

// const input_file = 'input_sample.txt'
// const input_file = 'input_sample_larger.txt'
// const input_file = 'input_wide_example.txt'
// const input_file = 'input_test.txt'
const input_file = 'input.txt'

fn main() {
	warehouse, warehouse_wide := read_file(input_file)!
	end_warehouse := do_instructions(warehouse, false)
	result := calculate_gps_sum(end_warehouse)
	println('${result}')

	end_warehouse_wide := do_instructions(warehouse_wide, false)
	result_wide := calculate_gps_sum(end_warehouse_wide)
	println('${result_wide}')
}

fn do_instructions(warehouse Warehouse, debug bool) Warehouse {
	mut fields := warehouse.fields.clone()
	mut robot_pos := warehouse.robot_pos
	for i, instruction in warehouse.instructions {
		if debug {
			println('${i} => ${instruction}')
		}
		next := robot_pos.next(instruction)
		moves, success := move(mut fields, next, instruction, false)
		if success {
			for this_move in moves {
				item := fields[this_move.from.y][this_move.from.x]
				fields[this_move.to.y][this_move.to.x] = item
				fields[this_move.from.y][this_move.from.x] = .nothing
			}
			robot_pos = next
		}
		if debug {
			print_map(Warehouse{
				robot_pos:    robot_pos
				fields:       fields
				instructions: []
			})
			time.sleep(time.millisecond * 16)
		}
	}

	return Warehouse{
		robot_pos:    robot_pos
		fields:       fields
		instructions: []
	}
}

fn calculate_gps_sum(warehouse Warehouse) int {
	mut result := 0
	for y, line in warehouse.fields {
		for x, item in line {
			if item in [.box, .box_left] {
				result += (100 * y) + x
			}
		}
	}

	return result
}

struct Move {
	from Coord
	to   Coord
}

fn move(mut fields Fields, coord Coord, direction Instruction, coming_from_pair bool) ([]Move, bool) {
	item := fields[coord.y][coord.x]
	if item == .nothing {
		return []Move{}, true
	}
	if item == .wall {
		return []Move{}, false
	}

	next := coord.next(direction)

	mut moves := []Move{}
	moves_prev, success := move(mut fields, next, direction, false)
	if !success {
		return []Move{}, false
	}
	moves << moves_prev.filter(!moves.contains(it))

	if direction in [.up, .down] {
		if item == .box_right && !coming_from_pair {
			moves_left, success_left := move(mut fields, coord.next(.left), direction,
				true)
			if !success_left {
				return []Move{}, false
			}
			moves << moves_left.filter(!moves.contains(it))
		}
		if item == .box_left && !coming_from_pair {
			moves_right, success_right := move(mut fields, coord.next(.right), direction,
				true)
			if !success_right {
				return []Move{}, false
			}
			moves << moves_right.filter(!moves.contains(it))
		}
	}

	this_move := Move{
		from: coord
		to:   next
	}
	if !moves.contains(this_move) {
		moves << this_move
	}

	return moves, true
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
	box_left
	box_right
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

fn read_file(name string) !(Warehouse, Warehouse) {
	mut robot_pos := Coord{}
	mut robot_pos_wide := Coord{}
	mut fields := map[int]map[int]MapElement{}
	mut fields_wide := map[int]map[int]MapElement{}

	data := os.read_file(name)!
	data_parts := data.split('\n\n')
	warehouse_str, instructions_str := data_parts[0], data_parts[1]

	for y, line in warehouse_str.split('\n') {
		mut this_line := map[int]MapElement{}
		mut this_line_wide := map[int]MapElement{}
		for x, field in line {
			elem, elems_wide := match field {
				`#` {
					MapElement.wall, [MapElement.wall].repeat(2)
				}
				`O` {
					MapElement.box, [MapElement.box_left, MapElement.box_right]
				}
				`.` {
					MapElement.nothing, [MapElement.nothing].repeat(2)
				}
				`@` {
					robot_pos = Coord{
						x: x
						y: y
					}
					robot_pos_wide = Coord{
						x: x * 2
						y: y
					}
					MapElement.nothing, [MapElement.nothing].repeat(2)
				}
				else {
					return error('unknown cell: ${field.str()}')
				}
			}
			this_line[x] = elem
			this_line_wide[x * 2], this_line_wide[x * 2 + 1] = elems_wide[0], elems_wide[1]
		}
		fields[y] = this_line.move()
		fields_wide[y] = this_line_wide.move()
	}

	instructions := instructions_str.runes().filter(it != `\n`).map(match it {
		`^` { Instruction.up }
		`>` { Instruction.right }
		`v` { Instruction.down }
		`<` { Instruction.left }
		else { return error('unknown instruction: ${it.str()}') }
	})

	warehouse := Warehouse{
		robot_pos:    robot_pos
		fields:       fields
		instructions: instructions
	}
	warehouse_wide := Warehouse{
		robot_pos:    robot_pos_wide
		fields:       fields_wide
		instructions: instructions
	}

	return warehouse, warehouse_wide
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
				print(term.bright_green('@'))
			} else {
				print(match elem {
					.box { term.bright_red('O') }
					.wall { term.bright_white('#') }
					.nothing { '.' }
					.box_left { term.bright_red('[') }
					.box_right { term.bright_red(']') }
				})
			}
		}
		println('')
	}
}
