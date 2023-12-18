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
      {1, 3},
      MapSet.new(),
      :gb_sets.singleton({0, {0, 0}, {:start, 0}})
    )
  end

  def second_star(path) do
    {:ok, file} = File.read(path)
    map = mappify(file)
    {rows, cols} = Enum.max(Map.keys(map))

    update_proposals(
      map,
      {rows, cols},
      {4, 10},
      MapSet.new(),
      :gb_sets.singleton({0, {0, 0}, {:start, 0}})
    )
  end

  defp update_proposals(map, target, step_range, visited, acc) do
    {prev = {loss, pos, dir}, rest} = :gb_sets.take_smallest(acc)

    if pos == target do
      loss
    else
      new_props =
        step(map, step_range, prev)
        |> Enum.map(fn {heat, new_pos, new_dir} ->
          {loss + heat, new_pos, new_dir}
        end)
        |> Enum.reject(fn {_, new_pos, new_dir} ->
          MapSet.member?(visited, {new_pos, new_dir})
        end)
        |> Enum.reduce(rest, fn el, acc -> :gb_sets.add_element(el, acc) end)

      update_proposals(
        map,
        target,
        step_range,
        MapSet.put(visited, {pos, dir}),
        new_props
      )
    end
  end

  defp step(map, {min_step, max_step}, {_, {row, col}, {dir, steps}}) do
    [
      {map[{row - 1, col}], {row - 1, col}, {:up, if(dir == :up, do: steps + 1, else: 1)}},
      {map[{row + 1, col}], {row + 1, col}, {:down, if(dir == :down, do: steps + 1, else: 1)}},
      {map[{row, col + 1}], {row, col + 1}, {:right, if(dir == :right, do: steps + 1, else: 1)}},
      {map[{row, col - 1}], {row, col - 1}, {:left, if(dir == :left, do: steps + 1, else: 1)}}
    ]
    |> Enum.filter(fn {_, _, {new_dir, _}} ->
      if steps < min_step do
        new_dir == dir || dir == :start
      else
        true
      end
    end)
    |> Enum.reject(fn {val, _, {new_dir, new_steps}} ->
      !val || new_steps > max_step ||
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
