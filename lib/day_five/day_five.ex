defmodule AdventOfCode.DayFive do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayFive` for AoC '23.
  """
  def first_star(path) do
    {:ok, file} = File.read(path)
    [seeds | maps] = String.split(file, "\n\n")

    seed_nums = get_seeds(seeds, :first)
    maps_fun = Enum.map(maps, &map_of_text/1)

    seed_nums
    |> Enum.map(&get_map_list(&1, maps_fun))
    |> Enum.min()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)
    [seeds | maps] = String.split(file, "\n\n")

    seed_nums = get_seeds(seeds, :second)
    maps_fun = Enum.map(maps, &map_of_text/1)

    seed_nums
    |> Stream.map(fn range ->
      Stream.map(range, &get_map_list(&1, maps_fun)) |> IO.inspect() |> Enum.min()
    end)
    |> Enum.min()
  end

  defp match_function(dest_start, source_start, steps) do
    compute_dest = fn source -> source - source_start + dest_start end

    fn
      source when source >= source_start and source < source_start + steps ->
        compute_dest.(source)

      _source ->
        nil
    end
  end

  defp get_map(value, fun_list) do
    Enum.find_value(fun_list, value, fn fun -> fun.(value) end)
  end

  defp get_map_list(value, map_list) do
    Enum.reduce(map_list, value, fn fun_list, acc -> get_map(acc, fun_list) end)
  end

  defp get_seeds(seeds, :first) do
    Regex.scan(~r/\d+/, seeds) |> List.flatten() |> Enum.map(&String.to_integer/1)
  end

  defp get_seeds(seeds, :second) do
    Regex.scan(~r/\d+ \d+/, seeds)
    |> Enum.map(fn [start_range] ->
      [start, range] = start_range |> String.split(" ") |> Enum.map(&String.to_integer/1)
      start..(start + range - 1)
    end)
  end

  defp map_of_text(str) do
    [_map, ranges] = String.split(str, ":\n")

    for range <- String.split(ranges, "\n", trim: true),
        [dest_start, source_start, steps] =
          String.split(range, ~r/\s+/) |> Enum.map(&String.to_integer/1) do
      match_function(dest_start, source_start, steps)
    end
  end

  defp map_of_text2(str) do
    [_map, ranges] = String.split(str, ":\n")
  end
end
