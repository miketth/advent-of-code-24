import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';

// const fileName = "input_sample.txt";
// const fileName = "input_sample2.txt";
const fileName = "input.txt";

void main() async {
  var maze = await readFile(fileName);

  var bestPaths = findBestPath(maze.map, maze.start, maze.end, Direction.Right);
  print(bestPaths.$2);

  var tilesOnBestPaths = <Coord>{};
  bestPaths.$1.forEach((path) => tilesOnBestPaths.addAll(path));
  print(tilesOnBestPaths.length+1);
}

class Coord {
  final int x;
  final int y;
  Coord(this.x, this.y);

  @override
  bool operator ==(Object other) {
    return other is Coord && other.x == this.x && other.y == this.y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

enum Tile {
  Road, Wall
}

class Maze {
  final List<List<Tile>> map;
  final Coord start;
  final Coord end;
  Maze(this.map, this.start, this.end);
}

Future<Maze> readFile(String fileName) async {
  var contents = await File(fileName).readAsString();
  var start = Coord(0,0);
  var end = Coord(0,0);

  var y = -1;
  var map = contents.split("\n").map((line) {
    y++;
    var x = -1;
    return line.split("").map((cell) {
      x++;
      if (cell == "#") {
        return Tile.Wall;
      }

      if (cell == "S") {
        start = Coord(x,y);
      }
      if (cell == "E") {
        end = Coord(x,y);
      }

      return Tile.Road;
    }).toList(growable: false);
  }).toList(growable: false);

  return Maze(map, start, end);
}

enum Direction { Up, Down, Left, Right }

class Solution {
  final List<Coord> path;
  final int cost;
  Solution(this.path, this.cost);
}

class Node {
  final Coord coord;
  final Direction direction;
  Node(this.coord, this.direction);

  @override
  bool operator ==(Object other) {
    return other is Node && other.coord == this.coord && other.direction == this.direction;
  }

  @override
  int get hashCode => Object.hash(coord, direction);
}

List<Node> neighbours(List<List<Tile>> map, Coord coord) {
  return [
    Node(Coord(coord.x, coord.y-1), Direction.Up),
    Node(Coord(coord.x+1, coord.y), Direction.Right),
    Node(Coord(coord.x, coord.y+1), Direction.Down),
    Node(Coord(coord.x-1, coord.y), Direction.Left),
  ].where((elem){
    var location = elem.coord;

    if (location.x < 0 || location.y < 0) {
      return false;
    }

    if (map.length <= location.y) {
      return false;
    }
    if (map[location.y].length <= location.x) {
      return false;
    }

    if (map[location.y][location.x] == Tile.Wall) {
      return false;
    }

    return true;
  }).toList(growable: false);
}

class NoPathForwardException implements Exception {
  NoPathForwardException() {
    Exception("no path forward");
  }
}


// This is a lousy implementation of Dijkstra's algorithm
(List<List<Coord>>, int) findBestPath(List<List<Tile>> map, Coord start, Coord end, Direction dir) {
  var queue = PriorityQueue<(Node, int)>((a,b) => a.$2.compareTo(b.$2));

  var distances = Map<Node, int>();
  var prevs = Map<Node, List<Node>>();

  var startNode = Node(start, dir);
  queue.add((startNode, 0));
  distances[startNode] = 0;

  while (queue.isNotEmpty) {
    var (node, prio) = queue.removeFirst();
    var nodeDistance = distances[node]!;
    neighbours(map, node.coord).forEach((neighbour) {
      var distance = nodeDistance + 1;
      if (node.direction != neighbour.direction) {
        distance += 1000;
      }
      var prevDistance = distances[neighbour] ?? double.maxFinite.toInt();

      // new best path to node
      if (distance < prevDistance) {
        distances[neighbour] = distance;
        prevs[neighbour] = [ node ];
        queue.add((neighbour, distance));
      }

      // alt path to node
      if (distance == prevDistance) {
        var prevsOfNei = prevs[neighbour] ?? [];
        prevsOfNei.add(node);
        prevs[neighbour] = prevsOfNei;
      }
    });
  }

  var minCost = double.maxFinite.toInt();
  var endNodes = <Node>[];
  distances.forEach((node, cost) {
    if (node.coord == end && cost <= minCost) {
      minCost = cost;
      endNodes.add(node);
    }
  });

  var paths = endNodes.map((node) => buildPaths(prevs, node, startNode)).flattenedToList;

  return (paths, minCost);
}

List<List<Coord>> buildPaths(Map<Node, List<Node>> prevs, Node end, Node start) {
  var prevNodes = prevs[end];
  if (prevNodes == null) {
    return [[start.coord]];
  }

  var paths = prevNodes.map((node) {
    var prevPaths = buildPaths(prevs, node, start);
    return prevPaths.map((path) => path + [node.coord]).toList(growable: false);
  }).flattenedToList;

  return paths;
}

