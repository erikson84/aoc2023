defmodule AdventOfCode.DayTwentyFive do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyFive` for AoC '23.
  """
  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc ->
      {node, children_list} = process_line(line)

      Map.update(acc, node, children_list, fn lst -> lst ++ children_list end)
      |> add_nodes(node, children_list)
    end)
    |> then(fn graph ->
      Enum.find(
        Stream.repeatedly(fn -> reduce(graph, 2) end),
        fn map ->
          len = Map.values(map) |> Enum.at(0) |> length()
          len == 3
        end
      )
    end)
    |> then(fn map ->
      Map.keys(map) |> Enum.map(fn key -> String.split(key, ", ") |> length() end)
    end)
    |> Enum.product()
  end

  def second_star(path), do: first_star(path)

  defp reduce(graph, size) when map_size(graph) == size, do: graph

  defp reduce(graph, size) do
    node_1 = Enum.random(Map.keys(graph))
    node_2 = Enum.random(graph[node_1])
    reduce(contract_nodes(graph, node_1, node_2), size)
  end

  defp contract_nodes(graph, node_1, node_2) do
    for {node, children} <- graph,
        node not in [node_1, node_2],
        into: %{} do
      {node,
       Enum.map(children, fn
         node when node in [node_1, node_2] -> "#{node_1}, #{node_2}"
         node -> node
       end)}
    end
    |> Map.put(
      "#{node_1}, #{node_2}",
      (graph[node_1] ++ graph[node_2])
      |> Enum.reject(fn node -> node in [node_1, node_2] end)
    )
  end

  defp process_line(line) do
    [node, children] = String.split(line, ": ")
    children_list = String.split(children, " ", trim: true)
    {node, children_list}
  end

  defp add_nodes(map, node, children_list) do
    Enum.reduce(children_list, map, fn child_node, acc ->
      Map.update(acc, child_node, [node], fn lst ->
        lst ++ [node]
      end)
    end)
  end
end
