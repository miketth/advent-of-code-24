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
  is_valid_helper(Nums, ThisRound, SumAchieved).

is_valid_helper([Num|Nums], SumSoFar, SumAchieved) :-
  ThisRound is SumSoFar + Num,
  is_valid_helper(Nums, ThisRound, SumAchieved).

is_valid_helper([], Sum, Sum).



main :-
  file_to_string("input.txt", FileContents),
  split_string(FileContents, "\n", "", Lines),
  process_lines(Lines, Data),
  count_valid_calibrations_sum(Data, Valid),
  write(Valid).
