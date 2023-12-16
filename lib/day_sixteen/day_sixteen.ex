defmodule AdventOfCode.DaySixteen do
  @moduledoc """
    Implements solutions for the first and second star
    of `DaySixteen` for AoC '23.
  """

  def first_star(path) do
    {:ok, string} = File.read(path)

    map = mappify(string)

    acc = Map.new(map, fn {key, _} -> {key, []} end)

    ray_tracing(map, {:right, {0, 0}}, acc)
    |> count_active()
  end

  def second_star(path) do
    {:ok, string} = File.read(path)
    map = mappify(string)
    acc = Map.new(map, fn {key, _} -> {key, []} end)
    {rows, cols} = Enum.max(Map.keys(map))

    by_row =
      for row <- 0..rows do
        [{:right, {row, 0}}, {:left, {row, cols}}]
      end
      |> List.flatten()

    by_col =
      for col <- 0..cols do
        [{:down, {0, col}}, {:up, {rows, col}}]
      end
      |> List.flatten()

    (by_row ++ by_col)
    |> Enum.map(fn step -> Task.async(fn -> ray_tracing(map, step, acc) |> count_active() end) end)
    |> Task.await_many()
    |> Enum.max()
  end

  defp ray_tracing(map, {direction, {row, col}}, acc) do
    if !acc[{row, col}] || direction in acc[{row, col}] do
      acc
    else
      new_direction =
        case {direction, map[{row, col}]} do
          {_, nil} -> nil
          {:right, "/"} -> :up
          {:right, "\\"} -> :down
          {:right, "|"} -> {:up, :down}
          {:right, _} -> :right
          {:left, "/"} -> :down
          {:left, "\\"} -> :up
          {:left, "|"} -> {:up, :down}
          {:left, _} -> :left
          {:up, "/"} -> :right
          {:up, "\\"} -> :left
          {:up, "-"} -> {:left, :right}
          {:up, _} -> :up
          {:down, "/"} -> :left
          {:down, "\\"} -> :right
          {:down, "-"} -> {:left, :right}
          {:down, _} -> :down
        end

      case new_direction do
        :right ->
          ray_tracing(
            map,
            {:right, {row, col + 1}},
            Map.update!(acc, {row, col}, &[direction | &1])
          )

        :left ->
          ray_tracing(
            map,
            {:left, {row, col - 1}},
            Map.update!(acc, {row, col}, &[direction | &1])
          )

        :up ->
          ray_tracing(
            map,
            {:up, {row - 1, col}},
            Map.update!(acc, {row, col}, &[direction | &1])
          )

        :down ->
          ray_tracing(
            map,
            {:down, {row + 1, col}},
            Map.update!(acc, {row, col}, &[direction | &1])
          )

        {:up, :down} ->
          ray_tracing(
            map,
            {:up, {row - 1, col}},
            ray_tracing(
              map,
              {:down, {row + 1, col}},
              Map.update!(acc, {row, col}, &[direction | &1])
            )
          )

        {:left, :right} ->
          ray_tracing(
            map,
            {:left, {row, col - 1}},
            ray_tracing(
              map,
              {:right, {row, col + 1}},
              Map.update!(acc, {row, col}, &[direction | &1])
            )
          )

        nil ->
          acc
      end
    end
  end

  defp count_active(map) do
    map
    |> Enum.reject(fn {_, list} -> list == [] end)
    |> Enum.count()
  end

  defp mappify(str) do
    for {row, row_idx} <- str |> String.split("\n", trim: true) |> Enum.with_index(),
        {el, col_idx} <- row |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{row_idx, col_idx}, el}
    end
  end
end
