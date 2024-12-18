# frozen_string_literal: true

def main
  # input_file = "input_sample.txt"
  input_file = 'input.txt'
  # end_coord = [6,6]
  end_coord = [70, 70]
  # bytes = 12
  bytes = 1024
  start_coord = [0, 0]

  obstacles = read_file(input_file)

  min_cost = path_finder(obstacles[0, bytes], start_coord, end_coord)
  puts min_cost

  good_until = bin_search(obstacles, start_coord, end_coord)
  puts obstacles[good_until - 1].join(',')
end

def bin_search(obstacles, start_coord, end_coord)
  range_start = 0
  range_end = obstacles.length

  while range_start != range_end
    midpoint = range_start + ((range_end - range_start) / 2)
    obstacles_current = obstacles[0, midpoint]

    cost = path_finder(obstacles_current, start_coord, end_coord)

    if cost < Float::INFINITY # success, bin search up
      range_start = midpoint + 1
    else # fail, bin search down
      range_end = midpoint
    end
  end

  range_start
end

def path_finder(obstacles, start_coord, end_coord)
  queue = PrioQueue.new
  distances = {}

  queue.put(0, start_coord)
  distances[start_coord] = 0

  while queue.not_empty?
    node = queue.get
    node_distance = distances[node]

    x, y = node[0], node[1]

    neighbours = [
      [x - 1, y],
      [x + 1, y],
      [x, y - 1],
      [x, y + 1]
    ].filter { |it| it[0] >= 0 && it[1] >= 0 && it[0] <= end_coord[0] && it[1] <= end_coord[1] }
                 .filter { |it| !obstacles.include?(it) }

    neighbours.each do |neighbour|
      prev_distance = distances[neighbour] || Float::INFINITY
      new_distance = node_distance + 1

      # new best path
      if new_distance < prev_distance
        distances[neighbour] = new_distance
        queue.put(new_distance, neighbour)
      end
    end
  end

  min_cost = Float::INFINITY
  distances.each do |node, distance|
    if node == end_coord && distance < min_cost
      min_cost = distance
    end
  end

  min_cost
end

class PrioQueue
  def initialize
    @hash = {}
  end

  def put(prio, value)
    arr = @hash[prio] || []
    arr.push(value)
    @hash[prio] = arr
  end

  def get
    min_prio = @hash.min_by { |key, _| key }

    key, val = min_prio[0], min_prio[1]
    ret = val.shift
    if val.empty?
      @hash.delete(key)
    end
    ret
  end

  def not_empty?
    !@hash.empty?
  end
end

def read_file(file_name)
  File.open(file_name, 'r')
      .read.split("\n")
      .map { |line| line.split(',').map(&:to_i) }
end

main

