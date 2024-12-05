defmodule Aoc24 do
  def start(_type, _args) do
    Main.main()
    {:ok, self()}
  end
end
