defmodule Main do
  def main() do
    {rules, prints} =
      File.read!("input.txt")
      |> String.split("\n")
      |> parse()
    solution =
      prints
      |> Enum.filter(fn item -> is_valid?(item, rules) end)
      |> Enum.map(&middle/1)
      |> Enum.sum()
    IO.inspect(solution)
  end

  def is_valid?(print, rules) do is_valid?(print, rules, []) end
  def is_valid?([], _rules, _seen) do true end
  def is_valid?([page | pages], rules, seen) do
    rules_for_page = default(rules[page])
    bad =
      rules_for_page
      |> Enum.any?(fn item -> Enum.member?(seen, item) end)
    if bad do
      false
    else
      is_valid?(pages, rules, [page | seen])
    end
  end

  def parse_rules(["" | lines], rules) do parse_prints(lines, rules) end
  def parse_rules([line | lines], rules) do
    [ first, second ] = String.split(line, "|") |> Enum.map(&String.to_integer/1)
    rulesForKey = rules[first];
    rules = Map.put(rules, first, prepend(second, rulesForKey))
    parse_rules(lines, rules)
  end
  def parse(lines) do parse_rules(lines, %{}) end

  def parse_prints(lines, rules) do parse_prints(lines, rules, []) end
  def parse_prints([], rules, prints) do { rules, prints } end
  def parse_prints([""], rules, prints) do { rules, prints } end
  def parse_prints([line | lines], rules, prints) do
    pages = String.split(line, ",") |> Enum.map(&String.to_integer/1)
    parse_prints(lines, rules, prints ++ [pages])
  end

  def prepend(item, nil) do [ item ] end
  def prepend(item, list) do [ item | list ] end

  def default(nil) do [] end
  def default(list) do list end

  def middle(list) do
    middle_idx = list |> length() |> div(2)
    Enum.at(list, middle_idx)
  end
end
