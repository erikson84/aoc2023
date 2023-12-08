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
    traverse_network(map, path, "AAA")
  end

  @spec second_star(String.t()) :: non_neg_integer()
  def second_star(path) do
    {:ok, file} = File.read(path)
    [path_str, map_str] = String.split(file, "\n\n")
    path = get_path(path_str)
    map = get_network_map(map_str)

    Map.keys(map)
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(fn start -> Task.async(fn -> traverse_network(map, path, start) end) end)
    |> Task.await_many()
    |> lcm()
  end

  @spec traverse_network(network(), Stream.t(), String.t()) :: non_neg_integer()
  defp traverse_network(map, path, start),
    do:
      Enum.reduce_while(path, {start, 0}, fn
        _, {<<_, _, ?Z>>, steps} -> {:halt, steps}
        direction, {node, steps} -> {:cont, {map[node][direction], steps + 1}}
      end)

  defp lcm(a, b) do
    div(a * b, Integer.gcd(a, b))
  end

  defp lcm(list) do
    Enum.reduce(list, &lcm(&2, &1))
  end

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
      |> Enum.map(&(Regex.scan(~r/[0-9A-Z]{3}/, &1) |> List.flatten()))
      |> Map.new(fn [node, left, right] -> {node, %{left: left, right: right}} end)
end
