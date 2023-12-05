defmodule DayTwo do
  @config %{red: 12, green: 13, blue: 14}
  @moduledoc """
  Documentation for `DayTwo`.
  """
  def check_valid_games(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      [game, tallies] =
        line
        |> String.trim()
        |> String.split(": ")

      {get_game(game), get_tallies(tallies) |> Enum.all?(&possible?(&1, @config))}
    end)
    |> Stream.filter(&elem(&1, 1))
    |> Stream.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def count_min_sets(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      [_game, tallies] = String.trim(line) |> String.split(": ")
      get_tallies(tallies) |> minimum_set() |> Map.values() |> Enum.product()
    end)
    |> Enum.sum()
  end

  defp possible?(game, config) do
    Enum.all?(Map.keys(game), &Map.has_key?(config, &1)) &&
      Enum.all?(game, fn {key, val} -> config[key] >= val end)
  end

  defp minimum_set(tallies) do
    Enum.reduce(tallies, fn map, acc ->
      Map.merge(acc, map, fn _k, val_acc, val_map ->
        if(val_map > val_acc, do: val_map, else: val_acc)
      end)
    end)
  end

  defp get_game(str) do
    Regex.run(~r/Game (\d+)/, str) |> Enum.at(1) |> String.to_integer()
  end

  defp get_tallies(str) do
    str
    |> String.split("; ")
    |> Enum.map(&map_of_tally/1)
  end

  defp map_of_tally(tally) do
    tally
    |> String.split(", ")
    |> Enum.reduce(%{}, fn count, acc ->
      String.split(count, " ")
      |> case do
        [number, color] -> Map.put(acc, String.to_atom(color), String.to_integer(number))
      end
    end)
  end
end
