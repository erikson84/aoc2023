defmodule AdventOfCode.DayFive do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayFive` for AoC '23.
  """
  def first_star(path) do
    {:ok, file} = File.read(path)
    [seeds | maps] = String.split(file, "\n\n")

    seed_nums = get_seeds(seeds, :first)
    maps = Enum.map(maps, &map_of_text/1)

    seed_nums
    |> Enum.flat_map(fn range -> get_map_list([range], maps) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)
    [seeds | maps] = String.split(file, "\n\n")

    seed_nums = get_seeds(seeds, :second)

    maps = Enum.map(maps, &map_of_text/1)

    seed_nums
    |> Enum.flat_map(fn range -> get_map_list([range], maps) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.min()
  end

  defp get_seeds(seeds, :first) do
    Regex.scan(~r/\d+/, seeds)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&{&1, &1})
  end

  defp get_seeds(seeds, :second) do
    Regex.scan(~r/\d+ \d+/, seeds)
    |> Enum.map(fn [start_range] ->
      [start, range] = start_range |> String.split(" ") |> Enum.map(&String.to_integer/1)
      {start, start + range - 1}
    end)
  end

  defp map_of_text(str) do
    [_map, ranges] = String.split(str, ":\n")

    for range <- String.split(ranges, "\n", trim: true),
        [dest_start, source_start, steps] =
          String.split(range, ~r/\s+/) |> Enum.map(&String.to_integer/1) do
      {{source_start, source_start + steps - 1}, dest_start - source_start}
    end
    |> Enum.sort_by(&elem(&1, 0))
    |> interpolate()
  end

  defp interpolate(lst), do: interpolate(lst, [])

  defp interpolate([last = {{_, stop}, _}], acc) do
    Enum.reverse([{{stop + 1, :inf}, 0}, last | acc])
    |> case do
      res = [{{0, _}, _} | _] -> res
      res = [{{start, _}, _} | _] -> [{{0, start - 1}, 0} | res]
    end
  end

  defp interpolate([fst = {{_, stop}, _}, snd = {{start, _}, _} | rest], acc)
       when start - stop == 1 do
    interpolate([snd | rest], [fst | acc])
  end

  defp interpolate([fst = {{_, stop}, _}, snd = {{start, _}, _} | rest], acc) do
    interpolate([snd | rest], [{{stop + 1, start - 1}, 0}, fst | acc])
  end

  defp get_map({start_value, stop_value}, map, acc) do
    case Enum.find(map, fn {range, _} -> in_range?(start_value, range) end) do
      {{_start_match, stop_match}, diff} when stop_value <= stop_match ->
        [{start_value + diff, stop_value + diff} | acc]

      {{_start_match, stop_match}, diff} ->
        get_map({stop_match + 1, stop_value}, map, [{start_value + diff, stop_match + diff} | acc])
    end
  end

  defp in_range?(value, {start, stop}),
    do: value >= start && (stop == :inf || value <= stop)

  defp get_map_list(range, map_list) do
    Enum.reduce(map_list, range, fn map, acc ->
      Enum.flat_map(acc, &get_map(&1, map, []))
    end)
  end
end
