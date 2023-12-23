defmodule AdventOfCode.DayTwentyOne do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyOne` for AoC '23.

  Lagrange polynomial interpolation function due to
  https://github.com/mathsaey/adventofcode/blob/master/lib/2023/21.ex
  """
  def first_star(path) do
    {:ok, str} = File.read(path)

    {start, map, _} = process_map(str)

    percolate(map, :limited, start)
    |> Enum.at(64)
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    {start, map, {rows, cols}} = process_map(str)

    percolate(map, {rows, cols}, start)
    |> then(&Enum.map([0, 1, 2], fn x -> {x, Enum.at(&1, div(rows, 2) + x * (rows + 1))} end))
    |> lagrange()
    |> then(& &1.(div(26_501_365 - 65, 131)))
  end

  defp percolate(map, version, start) do
    [start]
    |> Stream.iterate(fn coords ->
      Enum.flat_map(coords, &get_neighbors(map, &1, version)) |> Enum.uniq()
    end)
    |> Stream.map(&length/1)
  end

  defp get_neighbors(map, {row, col}, :limited) do
    for {row_step, col_step} <- [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}],
        {row_step, col_step} not in map do
      {row_step, col_step}
    end
  end

  defp get_neighbors(map, {row, col}, {rows, cols}) do
    for {row_step, col_step} <- [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}],
        {map_coord(row_step, rows + 1), map_coord(col_step, cols + 1)} not in map do
      {row_step, col_step}
    end
  end

  defp map_coord(line, lines) when rem(line, lines) >= 0, do: rem(line, lines)
  defp map_coord(line, lines), do: lines + rem(line, lines)

  defp process_map(str) do
    comp_map =
      for {row_data, row} <- String.split(str, "\n", trim: true) |> Enum.with_index(),
          {cell_data, col} <- String.graphemes(row_data) |> Enum.with_index(),
          into: %{} do
        {{row, col}, cell_data}
      end

    start = Enum.find(comp_map, fn {_coord, val} -> val == "S" end) |> elem(0)
    dims = Enum.max(Map.keys(comp_map))

    map =
      Enum.filter(comp_map, fn {_coord, val} -> val == "#" end)
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    {start, map, dims}
  end

  defp lagrange([{x0, y0}, {x1, y1}, {x2, y2}]) do
    fn x ->
      t0 = div((x - x1) * (x - x2), (x0 - x1) * (x0 - x2)) * y0
      t1 = div((x - x0) * (x - x2), (x1 - x0) * (x1 - x2)) * y1
      t2 = div((x - x0) * (x - x1), (x2 - x0) * (x2 - x1)) * y2
      t0 + t1 + t2
    end
  end
end
