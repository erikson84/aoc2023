defmodule AdventOfCode.DayTwentyThree do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyThree` for AoC '23.
  """

  def first_star(path) do
    {:ok, str} = File.read(path)

    map =
      str
      |> map_of_str()

    {start, target} = Enum.min_max(Map.keys(map))

    build_graph(map)
    |> build_reduced_graph(start, target)
    |> find_paths(target, MapSet.new(), {start, 0})
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    map =
      str
      |> map_of_str()
      |> Map.new(fn {coord, _} -> {coord, "."} end)

    {start, target} = Enum.min_max(Map.keys(map))

    build_graph(map)
    |> build_reduced_graph(start, target)
    |> find_paths(target, MapSet.new(), {start, 0})
  end

  defp find_paths(_map, target, _visited, {target, steps}) do
    steps
  end

  defp find_paths(map, target, visited, {{row, col}, steps}) do
    neighbors = Map.get(map, {row, col}) |> Enum.reject(fn {coord, _} -> coord in visited end)

    case neighbors do
      [] ->
        0

      [{coord, dist}] ->
        find_paths(map, target, MapSet.put(visited, {row, col}), {coord, steps + dist})

      step_lst ->
        Enum.map(step_lst, fn {{row_step, col_step}, dist} ->
          find_paths(
            map,
            target,
            MapSet.put(visited, {row, col}),
            {{row_step, col_step}, steps + dist}
          )
        end)
        |> Enum.max()
    end
  end

  defp get_neighbors(map, {row, col}) do
    cands =
      case map[{row, col}] do
        ">" -> [{row, col + 1}]
        "<" -> [{row, col - 1}]
        "^" -> [{row - 1, col}]
        "v" -> [{row + 1, col}]
        _ -> [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
      end

    for {row_step, col_step} <- cands,
        Map.has_key?(map, {row_step, col_step}) do
      {row_step, col_step}
    end
  end

  defp build_graph(map) do
    map
    |> Enum.map(fn {coord, _} -> {coord, get_neighbors(map, coord)} end)
    |> Map.new()
  end

  defp build_reduced_graph(graph, start, target) do
    forks =
      graph
      |> Enum.filter(fn {_coord, children} -> length(children) > 2 end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.concat([start, target])
      |> MapSet.new()

    Enum.map(forks, fn coord ->
      next =
        Enum.flat_map(graph[coord], fn coord_step ->
          get_next(coord_step, coord, graph, forks, 1)
        end)

      {coord, next}
    end)
    |> Map.new()
  end

  defp get_next(cur, prev, graph, forks, len) do
    if cur in forks do
      [{cur, len}]
    else
      case graph[cur] do
        [nxt] when nxt == prev -> []
        [nxt] -> get_next(nxt, cur, graph, forks, len + 1)
        [n1, n2] -> get_next(if(n1 == prev, do: n2, else: n1), cur, graph, forks, len + 1)
      end
    end
  end

  defp map_of_str(str) do
    for {row, row_idx} <- String.split(str, "\n", trim: true) |> Enum.with_index(),
        {el, col_idx} <- String.graphemes(row) |> Enum.with_index(),
        el != "#",
        into: %{} do
      {{row_idx, col_idx}, el}
    end
  end
end
