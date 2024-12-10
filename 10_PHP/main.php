<?php

function main(): void
{
//    $file_path = "input_sample.txt";
    $file_path = "input.txt";

    $data = read_input($file_path);
    $start_points = find_0s($data);

    $sum_part_1 = 0;
    $sum_part_2 = 0;
    foreach ($start_points as $coord) {
        $reachable_peaks = find_reachable_peaks($data, $coord);
        $sum_part_1 += count(array_unique($reachable_peaks, SORT_REGULAR));
        $sum_part_2 += count($reachable_peaks);
    }
    echo $sum_part_1;
    echo "\n";
    echo $sum_part_2;
}

function find_reachable_peaks($map, $coord, $start_from = 0): array
{
    if ($start_from === 9) {
        return [$coord];
    }

    $reachable = [];
    foreach (neighbours($map, $coord) as $neighbour) {
        [$x, $y] = $neighbour;
        $val = $map[$y][$x];
        if ($val !== $start_from + 1) {
            continue;
        }
        $this_reachable = find_reachable_peaks($map, $neighbour, $start_from + 1);
        $reachable = array_merge($reachable, $this_reachable);
    }

    return $reachable;
}

function neighbours($map, $coord): array
{
    [$x, $y] = $coord;

    $nei = [
        [$x, $y-1],
        [$x, $y+1],
        [$x-1, $y],
        [$x+1, $y],
    ];
    $nei = array_filter($nei, static function ($neighbour) use ($map) {
        [$x, $y] = $neighbour;
        if ($x < 0 || $y < 0) {
            return false;
        }

        if ($y >= count($map) || $x >= count($map[$y])) {
            return false;
        }
        return true;
    });

    return $nei;
}

function find_0s($data): array
{
    $ret = [];

    for ($y = 0; $y < count($data); $y++) {
        for ($x = 0; $x < count($data[$y]); $x++) {
            if ($data[$y][$x] === 0) {
                $ret[] = [$x, $y];
            }
        }
    }

    return $ret;
}

function read_input($file_path): array
{
    $lines = file($file_path);
    $lines = array_map(function($line) {
        return trim($line);
    }, $lines);
    $lines = array_filter($lines, function($line) {
        return $line != "";
    });
    $data = array_map(function($line) {
        $split = str_split($line);
        return array_map(function($num) {
            if ($num === ".") {
                return null;
            }
            return intval($num);
        }, $split);
    }, $lines);
    return $data;
}


main();

