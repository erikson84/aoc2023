defmodule AdventOfCode.DaySeventeen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DaySeventeen` for AoC '23.
  """

  def first_star(path) do
    {:ok, file} = File.read(path)
    map = mappify(file)
    {rows, cols} = Enum.max(Map.keys(map))

    update_proposals(
      map,
      {rows, cols},
      MapSet.new(),
      :gb_sets.singleton({0, {0, 0}, {:start, 0}})
    )
  end

  defp update_proposals(map, target, visited, acc) do
    {prev = {loss, {row, col}, {dir, steps}}, rest} = :gb_sets.take_smallest(acc)

    if {row, col} == target do
      loss
    else
      new_props =
        step(map, prev)
        |> Enum.map(fn {heat, pos, dir} ->
          {loss + heat, pos, dir}
        end)
        |> Enum.reject(fn {_, pos, {new_dir, new_steps}} ->
          MapSet.member?(visited, {pos, new_dir, new_steps})
        end)

      acc =
        new_props
        |> Enum.reduce(rest, fn el, acc -> :gb_sets.add_element(el, acc) end)

      visited = MapSet.put(visited, {{row, col}, dir, steps})
      # new_props
      # |> Enum.reduce(visited, fn {val, pos, {dir, steps}}, acc ->
      #   MapSet.put(acc, {pos, dir, steps})
      # end)
      #
      update_proposals(
        map,
        target,
        visited,
        acc
      )
    end
  end

  defp step(map, {_, {row, col}, {dir, steps}}) do
    [
      {map[{row - 1, col}], {row - 1, col}, {:up, if(dir == :up, do: steps + 1, else: 1)}},
      {map[{row + 1, col}], {row + 1, col}, {:down, if(dir == :down, do: steps + 1, else: 1)}},
      {map[{row, col + 1}], {row, col + 1}, {:right, if(dir == :right, do: steps + 1, else: 1)}},
      {map[{row, col - 1}], {row, col - 1}, {:left, if(dir == :left, do: steps + 1, else: 1)}}
    ]
    |> Enum.reject(fn {val, _, {new_dir, new_steps}} ->
      !val || new_steps > 3 ||
        case {dir, new_dir} do
          {:up, :down} -> true
          {:down, :up} -> true
          {:left, :right} -> true
          {:right, :left} -> true
          {_, _} -> false
        end
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
