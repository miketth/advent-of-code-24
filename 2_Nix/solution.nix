{ lib, ... }:
let
  split = (separator: text:
    builtins.filter (part: part != "" && part != [] && part != "\n") (builtins.split separator text)
  );

  inputEnv = builtins.getEnv "INPUT";
  inputFile = if inputEnv != "" then inputEnv else ((builtins.getEnv "PWD") + "/input.txt");

  input = builtins.readFile inputFile;
  lines = split "\n" input;

  reports = map (line: let
    levelStrs = split " " line;
    levels = map (levelStr: lib.strings.toInt levelStr) levelStrs;
  in levels) lines;


  isSafeIncreasing = (report: let
    folded = builtins.foldl' ({ prev, goodSoFar }: item: {
      goodSoFar = goodSoFar && (
        prev == null || (
          item > prev && item <= prev + 3
        )
      );
      prev = item;
    }) {
      goodSoFar = true;
      prev = null;
    } report;
  in folded.goodSoFar);

  isSafeDecreasing = (report: let
    folded = builtins.foldl' ({ prev, goodSoFar }: item: {
      goodSoFar = goodSoFar && (
        prev == null || (
          item < prev && item >= prev - 3
        )
      );
      prev = item;
    }) {
      goodSoFar = true;
      prev = null;
    } report;
  in folded.goodSoFar);

  isSafe = (report: (isSafeIncreasing report) || (isSafeDecreasing report));

  safeness = map (report: isSafe report) reports;

  safeCount = builtins.foldl' (acc: item: if item then acc+1 else acc) 0 safeness;

in safeCount