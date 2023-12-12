defmodule AdventOfCode.DayTwelve do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwelve` for AoC '23.
  """
  def first_star(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      {string, counts} =
        line
        |> process_line()

      size = String.graphemes(string) |> Enum.count(&(&1 == "?"))

      combinations(size)
      |> Enum.map(fn sub -> splice(string, sub, "") end)
      |> Enum.count(fn strs -> count_hashes(strs) == counts end)
    end)
    |> Enum.sum()
  end

  defp count_hashes(str) do
    Regex.scan(~r/\#+/, str)
    |> Enum.map(fn [res] -> String.length(res) end)
  end

  defp combinations(0), do: [[]]

  defp combinations(size) do
    for char <- ["#", "."],
        rest <- combinations(size - 1) do
      [char | rest]
    end
  end

  defp splice(string, [], acc), do: acc <> string
  defp splice("?" <> rest, [char | chars], acc), do: splice(rest, chars, acc <> char)
  defp splice("#" <> rest, chars, acc), do: splice(rest, chars, acc <> "#")
  defp splice("." <> rest, chars, acc), do: splice(rest, chars, acc <> ".")

  defp process_line(line) do
    [string, counts] =
      line
      |> String.trim()
      |> String.split(~r/\s+/)

    {string, counts |> String.split(",") |> Enum.map(&String.to_integer/1)}
  end
end
