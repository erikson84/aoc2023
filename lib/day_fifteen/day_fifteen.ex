defmodule AdventOfCode.DayFifteen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayFifteen` for AoC '23.
  """
  def first_star(path) do
    {:ok, string} = File.read(path)

    string
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  defp hash(string, acc \\ 0)
  defp hash("", acc), do: acc
  defp hash(<<char, str::binary>>, acc), do: hash(str, rem((acc + char) * 17, 256))
end
