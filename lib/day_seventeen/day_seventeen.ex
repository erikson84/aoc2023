defmodule AdventOfCode.DaySeventeen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DaySeventeen` for AoC '23.
  """

  def first_star(path) do
    {:ok, file} = File.read(path)
    map = mappify(file)
    {rows, cols} = Enum.max(Map.keys(map))

    acc =
      (take_three(map, :right, {0, 0}) ++
         take_three(map, :down, {0, 0}))
      |> Enum.sort()

    visited = Map.new(map, fn {k, _} -> {k, false} end)
    update_proposals(map, {rows, cols}, visited, acc)
  end

  defp update_proposals(_map, {row, col}, _visited, [{dist, {row, col}, _} | _acc]),
    do: dist

  defp update_proposals(map, target, visited, [{dist, idx, direction} | acc]) do
    new_props =
      take_three(map, direction, idx)
      |> Enum.reject(fn {_, pos, _} -> visited[pos] end)
      |> Enum.map(fn {step, pos, dir} ->
        {dist + step, pos, dir}
      end)

    update_proposals(map, target, %{visited | idx => true}, insert_sorted(new_props, acc))
  end

  def insert_sorted(list, sorted) do
    {lst_bef, lst_aft} =
      Enum.reduce(Enum.sort(list), {[], sorted}, fn el = {dist, _, _}, {prev, curr} ->
        {bef, aft} = Enum.split_while(curr, fn {val, _, _} -> val < dist end)
        {prev ++ bef, [el | aft]}
      end)

    lst_bef ++ lst_aft
  end

  defp take_three(map, direction, {row, col}) when direction in [:right, :left] do
    {up, down} =
      for {dir, step} <- [
            {:down, 1},
            {:down, 2},
            {:down, 3},
            {:up, -1},
            {:up, -2},
            {:up, -3}
          ],
          val = map[{row + step, col}],
          val != nil do
        {val, {row + step, col}, dir}
      end
      |> Enum.split_with(fn {_, _, dir} -> dir == :down end)

    cumsum(up) ++ cumsum(down)
  end

  defp take_three(map, direction, {row, col}) when direction in [:up, :down] do
    {right, left} =
      for {dir, step} <- [
            {:right, 1},
            {:right, 2},
            {:right, 3},
            {:left, -1},
            {:left, -2},
            {:left, -3}
          ],
          val = map[{row, col + step}],
          val != nil do
        {val, {row, col + step}, dir}
      end
      |> Enum.split_with(fn {_, _, dir} -> dir == :right end)

    cumsum(right) ++ cumsum(left)
  end

  defp cumsum(list) do
    Enum.reduce(list, [], fn
      el, [] -> [el]
      {val, pos, dis}, acc = [{prev, _, _} | _] -> [{val + prev, pos, dis} | acc]
    end)
  end

  defp mappify(str) do
    for {row, row_idx} <- str |> String.split("\n", trim: true) |> Enum.with_index(),
        {el, col_idx} <- row |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{row_idx, col_idx}, String.to_integer(el)}
    end
  end
end
