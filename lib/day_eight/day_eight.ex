defmodule AdventOfCode.DayEight do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayEight` for AoC '23.
  """
  @type network :: %{String.t() => %{left: String.t(), right: String.t()}}

  @spec first_star(String.t()) :: non_neg_integer()
  def first_star(path) do
    {:ok, file} = File.read(path)
    [path_str, map_str] = String.split(file, "\n\n")
    path = get_path(path_str)
    map = get_network_map(map_str)
    traverse_network(map, path)
  end

  @spec traverse_network(network(), Stream.t()) :: non_neg_integer()
  defp traverse_network(map, path),
    do:
      Enum.reduce_while(path, {"AAA", 0}, fn
        _, {"ZZZ", num} -> {:halt, num}
        direction, {node, num} -> {:cont, {map[node][direction], num + 1}}
      end)

  @spec get_path(String.t()) :: Stream.t()
  defp get_path(str),
    do:
      str
      |> String.graphemes()
      |> Enum.map(fn
        "R" -> :right
        "L" -> :left
      end)
      |> Stream.cycle()

  @spec get_network_map(String.t()) :: network()
  defp get_network_map(str),
    do:
      str
      |> String.split("\n", trim: true)
      |> Enum.map(&(Regex.scan(~r/[A-Z]{3}/, &1) |> List.flatten()))
      |> Map.new(fn [node, left, right] -> {node, %{left: left, right: right}} end)
end
