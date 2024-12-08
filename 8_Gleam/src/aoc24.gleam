import gleam/int
import gleam/result
import gleam/dict
import gleam/list
import gleam/string
import simplifile
import gleam/io

//const input_file = "input_sample.txt"
const input_file = "input.txt"

type Coord = #(Int, Int)

pub fn main() {
  let #(data, bounds) = load_data()

  let antinode_count = find_all_antinodes(data, bounds, find_antinodes) |> list.length

  io.println(antinode_count |> int.to_string())

  let antinode_count_part2 = find_all_antinodes(data, bounds, find_antinodes_part2) |> list.length

  io.println(antinode_count_part2 |> int.to_string())
}

fn load_data() {
  let assert Ok(data) = simplifile.read(input_file)
  let data =
    data
    |> string.split("\n")
    |> list.filter(fn(line) { line != "" })
    |> list.map(fn (line) { string.split(line, "") })

  let lines = list.length(data)
  let first = result.unwrap(list.first(data), [])
  let columns = list.length(first)

  let coords =
    data
    |> list.index_map(fn (line, y) {
      line
      |> list.index_map(fn (cell, x) { #(cell, x, y) })
    })
    |> list.flatten()
    |> list.filter(fn (data) {
      case data {
        #(".", _, _) -> False
        _ -> True
      }
    })

  let coord_dict =
    coords
    |> list.fold(dict.new(), fn (acc, item) {
      let #(cell, x, y) = item
      let existing = result.unwrap(dict.get(acc, cell), [])
      dict.insert(acc, cell, [#(x,y), ..existing])
    })

  #(coord_dict, #(columns, lines))
}

fn find_antinodes(coords: List(Coord), bounds: Coord) {
  let #(x_size, y_size) = bounds

  list.combination_pairs(coords)
  |> list.map(fn (item) {
    let #(#(x1, y1), #(x2, y2)) = item
    let x_diff = x1-x2
    let y_diff = y1-y2
    [
      #(x1+x_diff, y1+y_diff),
      #(x2-x_diff, y2-y_diff)
    ]
  })
  |> list.flatten
  |> list.filter(fn (item) {
    let #(x, y) = item
    x < x_size && y < y_size && x >= 0 && y >= 0
  })
  |> list.unique
}

fn find_antinodes_part2(coords: List(Coord), bounds: Coord) {
  list.combination_pairs(coords)
  |> list.map(fn (item) {
    let #(tower1, tower2) = item
    find_grid_positions_inline(tower1, tower2, bounds)
  })
  |> list.flatten
  |> list.unique
}

fn find_grid_positions_inline(tower1: Coord, tower2: Coord, bounds: Coord) {
  let #(x1, y1) = tower1
  let #(x2, y2) = tower2
  let x_diff = x1-x2
  let y_diff = y1-y2

  let gcd = greatest_common_divisor(int.absolute_value(x_diff), int.absolute_value(y_diff))
  let step_forward = #(x_diff / gcd, y_diff / gcd)
  let step_backward = #(-x_diff / gcd, -y_diff / gcd)

  let forward = step_through(tower1, step_forward, bounds)
  let backward = step_through(tower1, step_backward, bounds)

  list.append(forward, backward)
}

fn step_through(from: Coord, step: Coord, bounds: Coord) {
  step_through_helper(from, step, bounds, [])
}

fn step_through_helper(from: Coord, step: Coord, bounds: Coord, acc: List(Coord)) {
  let #(prev_x, prev_y) = from
  let #(diff_x, diff_y) = step
  let #(bound_x, bound_y) = bounds

  let acc = [from, ..acc]

  let next = #(prev_x + diff_x, prev_y + diff_y)
  case next {
    #(x, y) if x < 0 || y < 0 -> acc
    #(x, y) if x >= bound_x || y >= bound_y -> acc
    _ -> step_through_helper(next, step, bounds, acc)
  }
}

fn greatest_common_divisor(a, b) {
  case b {
    0 -> a
    _ -> greatest_common_divisor(b, a % b)
  }
}

fn find_all_antinodes(data: dict.Dict(String, List(Coord)), bounds: Coord, finder: fn(List(Coord), Coord) -> List(Coord)) {
  data
  |> dict.map_values(fn (_key, item) {
    finder(item, bounds)
  })
  |> dict.fold([], fn (acc, _key, val) {
    list.append(acc, val)
  })
  |> list.unique
}
