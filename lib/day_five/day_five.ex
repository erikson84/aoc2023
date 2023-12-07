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

    seed_nums = IO.inspect(get_seeds(seeds, :second))

    # maps = IO.inspect(Enum.map(maps, &map_of_text2/1))
    maps = IO.inspect(Enum.map(maps, &map_of_text/1))

    seed_nums
    |> Enum.flat_map(fn {start, steps} ->
      start..(start + steps - 1)
      |> Enum.map(&get_map_list(&1, maps))
    end)

    #    |> Enum.sort_by(&elem(&1, 0))

    # end)
    # |> Enum.min()
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
      {start, range}
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

    for range <- String.split(ranges, "\n", trim: true),
        [dest_start, source_start, steps] =
          String.split(range, ~r/\s+/) |> Enum.map(&String.to_integer/1) do
      {{source_start, steps}, dest_start - source_start}
    end
    |> Enum.sort_by(&elem(&1, 0))
    |> interpolate()
  end

  defp interpolate(lst), do: interpolate(lst, [])

  defp interpolate([last = {{start, steps}, _}], acc),
    do:
      Enum.reverse([{{start + steps, :inf}, 0}, last | acc])
      |> then(
        &if(hd(&1) |> elem(0) |> elem(0) != 0,
          do: [{{0, hd(&1) |> elem(0) |> elem(0)}, 0} | &1],
          else: &1
        )
      )

  defp interpolate(
         [fst = {{start_fst, steps_fst}, _}, snd = {{start_snd, _steps_snd}, _} | rest],
         acc
       )
       when start_fst + steps_fst == start_snd do
    interpolate([snd | rest], [fst | acc])
  end

  defp interpolate(
         [fst = {{start_fst, steps_fst}, _}, snd = {{start_snd, _steps_snd}, _} | rest],
         acc
       ) do
    interpolate([snd | rest], [
      {{start_fst + steps_fst, start_snd - (start_fst + steps_fst)}, 0},
      fst | acc
    ])
  end

  defp get_map2({start_value, range}, map, acc) do
    case Enum.find(map, fn {range, _} -> in_range?(start_value, range) end) do
      {{_start_match, range_match}, diff} when range <= range_match ->
        [{start_value + IO.inspect(diff, label: "Diff no split"), range} | acc]
        |> Enum.sort_by(&elem(&1, 0))

      {{start_match, range_match}, diff} ->
        get_map2(
          {start_match + range_match, range - (start_match + range_match - 1 - start_value)},
          map,
          [
            {start_value + IO.inspect(diff, label: "Diff split"),
             start_match + range_match - 1 - start_value}
            | acc
          ]
        )

      nil ->
        IO.puts("{#{start_value}, #{range}}")
        IO.puts(map)
        raise "Erro: {#{start_value}, #{range}}"
    end
  end

  defp in_range?(value, {start, steps}),
    do: value >= start && (steps == :inf || value <= start + steps - 1)

  defp get_map_list2(range, map_list) do
    Enum.reduce(map_list, range, fn map, acc ->
      Enum.flat_map(acc, &get_map2(&1, map, []))
    end)
  end
end
