<?php

function main(): void
{
//    $filePath = "input_sample.txt";
    $filePath = "input.txt";

    $data = read_input($filePath);
    $startPoints = find_0s($data);

    $sum = 0;
    foreach ($startPoints as $coord) {
        $reachable_peaks = find_reachable_peaks($data, $coord);
        $sum += count($reachable_peaks);
    }
    echo $sum;
}

function find_reachable_peaks($map, $coord, $startFrom = 0): array
{
    if ($startFrom === 9) {
        return [$coord];
    }

    $reachable = [];
    foreach (neighbours($map, $coord) as $neighbour) {
        [$x, $y] = $neighbour;
        $val = $map[$y][$x];
        if ($val !== $startFrom + 1) {
            continue;
        }
        $thisReachable = find_reachable_peaks($map, $neighbour, $startFrom + 1);
        $reachable = array_merge($reachable, $thisReachable);
    }

    return array_unique($reachable, SORT_REGULAR);
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

function read_input($filePath): array
{
    $lines = file($filePath);
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

