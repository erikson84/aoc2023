defmodule AdventOfCode.DayTen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTen` for AoC '23.
  """

  defp map_of_str(str) do
    map = matrixify(str)
    {rows, cols} = {Enum.count(map), Enum.count(Enum.at(map, 0))}
start = {Enum.find_index(map, fn row -> "S" in row end),  ww
    fn
      {:dims} -> {rows, cols}
      {:at, {row, col}} -> map |> Enum.at(row) |> Enum.at(col)
    end
  end

  defp matrixify(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end
end
