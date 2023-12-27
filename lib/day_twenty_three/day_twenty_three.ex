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

    start =
      Enum.find_value(map, fn {{row, col}, val} -> if val == "." && row == 0, do: {row, col} end)

    target =
      Enum.find_value(map, fn {{row, col}, val} ->
        last_row = Enum.max(Map.keys(map)) |> elem(0)
        if val == "." && row == last_row, do: {row, col}
      end)

    find_paths(map, target, MapSet.new(), [start])
    |> List.flatten()
    |> Enum.max()
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    map =
      str
      |> map_of_str()
      |> Map.new(fn {coord, val} ->
        if val in ["<", ">", "^", "v", "."], do: {coord, "."}, else: {coord, val}
      end)

    start =
      Enum.find_value(map, fn {{row, col}, val} -> if val == "." && row == 0, do: {row, col} end)

    target =
      Enum.find_value(map, fn {{row, col}, val} ->
        last_row = Enum.max(Map.keys(map)) |> elem(0)
        if val == "." && row == last_row, do: {row, col}
      end)

    find_paths(map, target, MapSet.new(), [start])
    |> List.flatten()
    |> Enum.max()
  end

  defp find_paths(_map, target, _visited, [target | path]) do
    length([target | path]) - 1
  end

  defp find_paths(map, target, visited, [{row, col} | path]) do
    neighbors = get_neighbors(map, {row, col}) |> Enum.reject(&(&1 in visited))

    case neighbors do
      [] ->
        0

      [step] ->
        find_paths(map, target, MapSet.put(visited, {row, col}), [step, {row, col} | path])

      steps ->
        Enum.map(steps, fn {row_step, col_step} ->
          find_paths(
            map,
            target,
            MapSet.put(visited, {row, col}),
            [{row_step, col_step}, {row, col} | path]
          )
        end)
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
        val = map[{row_step, col_step}],
        !val || val != "#" do
      {row_step, col_step}
    end
  end

  defp map_of_str(str) do
    for {row, row_idx} <- String.split(str, "\n", trim: true) |> Enum.with_index(),
        {el, col_idx} <- String.graphemes(row) |> Enum.with_index(),
        into: %{} do
      {{row_idx, col_idx}, el}
    end
  end
end
