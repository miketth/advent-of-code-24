defmodule Aoc24 do
  def start(_type, _args) do
    Main.main()
    System.halt(0)
    {:ok, self()}
  end
end
