defmodule AdventOfCode.DayFourteen do
  @moduledoc """
    Implements solutions for the first and second star
    of `DayTwelve` for AoC '23. 
  """
  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> count_stones()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> then(&Enum.reduce(1..1_000, {&1, %{}}, fn _, {map, cache} -> cycle(map, cache) end))
    |> elem(0)
    |> count_stones()
  end

  defp move_line(string, direction) do
    Regex.scan(~r/(?:[^\#]+|\#+)/, string)
    |> Enum.map(fn
      [str = "#" <> _rest] -> str
      [str] when direction == :up -> String.graphemes(str) |> Enum.sort(:desc)
      [str] when direction == :down -> String.graphemes(str) |> Enum.sort()
    end)
    |> Enum.join()
  end

  defp count_stones(map) do
    map
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {str, idx} ->
      String.graphemes(str) |> Enum.count(&(&1 == "O")) |> then(&(&1 * idx))
    end)
    |> Enum.sum()
  end

  defp transpose(map) do
    Enum.map(map, &String.graphemes/1)
    |> Enum.zip_with(& &1)
    |> Enum.map(&Enum.join/1)
  end

  defp cycle(map, cache) do
    if val = cache[map] do
      {val, cache}
    else
      val = cycle(map)
      {val, Map.put(cache, map, val)}
    end
  end

  defp cycle(map) do
    map
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> Enum.map(&move_line(&1, :down))
    |> transpose()
    |> Enum.map(&move_line(&1, :down))
  end
end
