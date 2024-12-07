file_to_string(FilePath, String) :-
  open(FilePath, read, Stream),
  read_string(Stream, _, String),
  close(Stream).

process_line(Line, calibration(Sum, Nums)) :-
  split_string(Line, ": ", "", [Header, _ | NumStrings]),
  number_string(Sum, Header),
  maplist(number_string, Nums, NumStrings).

process_lines([], []).
process_lines([""], []).
process_lines([Line | Lines], [Data|Datas]) :-
  process_line(Line, Data),
  process_lines(Lines, Datas).

count_valid_calibrations_sum([], 0).
count_valid_calibrations_sum([Data|Datas], Sum) :-
  calibration(ThisSum, _) = Data,
  count_valid_calibrations_sum(Datas, SumSoFar),
  (is_valid(Data) -> Sum is SumSoFar + ThisSum; Sum = SumSoFar).

is_valid(calibration(Sum, Nums)) :-
  Sum = SumAchieved,
  is_valid_helper(Nums, 0, SumAchieved).

is_valid_helper([Num|Nums], SumSoFar, SumAchieved) :-
  ThisRound is SumSoFar * Num,
  \+ ThisRound > SumAchieved, % optimization for quitting early
  is_valid_helper(Nums, ThisRound, SumAchieved).

is_valid_helper([Num|Nums], SumSoFar, SumAchieved) :-
  ThisRound is SumSoFar + Num,
  \+ ThisRound > SumAchieved, % optimization for quitting early
  is_valid_helper(Nums, ThisRound, SumAchieved).

is_valid_helper([], Sum, Sum).

count_valid_calibrations_sum_part2([], 0).
count_valid_calibrations_sum_part2([Data|Datas], Sum) :-
  calibration(ThisSum, _) = Data,
  count_valid_calibrations_sum_part2(Datas, SumSoFar),
  (is_valid_part2(Data) -> Sum is SumSoFar + ThisSum; Sum = SumSoFar).

is_valid_part2(calibration(Sum, Nums)) :-
  Sum = SumAchieved,
  is_valid_helper_part2(Nums, 0, SumAchieved).

is_valid_helper_part2([Num|Nums], SumSoFar, SumAchieved) :-
  ThisRound is SumSoFar * Num,
  \+ ThisRound > SumAchieved, % optimization for quitting early
  is_valid_helper_part2(Nums, ThisRound, SumAchieved).

is_valid_helper_part2([Num|Nums], SumSoFar, SumAchieved) :-
  ThisRound is SumSoFar + Num,
  \+ ThisRound > SumAchieved, % optimization for quitting early
  is_valid_helper_part2(Nums, ThisRound, SumAchieved).

is_valid_helper_part2([Num|Nums], SumSoFar, SumAchieved) :-
  concat_num(SumSoFar, Num, ThisRound),
  \+ ThisRound > SumAchieved, % optimization for quitting early
  is_valid_helper_part2(Nums, ThisRound, SumAchieved).

is_valid_helper_part2([], Sum, Sum).

digits(0, 1).
digits(Num, Digits) :-
  \+ Num is 0,
  Digits is integer(log10(Num)) + 1.

concat_num(Num1, Num2, Result) :-
  digits(Num2, Digits), !,
  Num1Shifted is Num1 * (10 ^ Digits),
  Result is Num1Shifted + Num2.

main :-
  file_to_string("input.txt", FileContents),
  split_string(FileContents, "\n", "", Lines),
  process_lines(Lines, Data),
  count_valid_calibrations_sum(Data, Valid),
  write(Valid),
  write("\n"),
  count_valid_calibrations_sum_part2(Data, Valid2),
  write(Valid2),
  write("\n").
