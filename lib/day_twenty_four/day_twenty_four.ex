defmodule AdventOfCode.DayTwentyFour do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyFour` for AoC '23.

  For the second challenge, the code generate the adequate system
  of equations, which are solved elsewhere.
  Equations based on 
  https://github.com/ash42/adventofcode/blob/main/adventofcode2023/src/nl/michielgraat/adventofcode2023/day24/Day24.java
  """
  @min 200_000_000_000_000
  @max 400_000_000_000_000

  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_pos_vel/1)
    |> compare_pairs()
    |> Enum.filter(fn
      {x, y} -> x > @min and x < @max and y > @min and y < @max
      _ -> false
    end)
    |> Enum.count()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_pos_vel/1)
    |> Enum.take(4)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn pair -> build_equation(pair) end)
    |> gaussian_elimination()
    |> solve()
    |> Enum.take(3)
    |> Enum.map(&round/1)
    |> Enum.sum()
  end

  defp compare_pairs([]), do: []

  defp compare_pairs([point | points]) do
    for other_point <- points do
      find_intersection(point, other_point)
    end ++
      compare_pairs(points)
  end

  def find_intersection(p1, p2) do
    {a1, b1} = ab_line(p1)
    {a2, b2} = ab_line(p2)

    if b1 - b2 == 0 do
      :collinear
    else
      x = (a2 - a1) / (b1 - b2)
      y = a1 + b1 * x

      case {check_time(p1, {x, y}), check_time(p2, {x, y})} do
        {r1, _} when r1 < 0 -> :past
        {_, r2} when r2 < 0 -> :past
        _ -> {x, y}
      end
    end
  end

  defp ab_line({pos, vel}) do
    {x, y, _} = pos
    {dx, dy, _} = vel
    beta = dy / dx
    alpha = y - beta * x
    {alpha, beta}
  end

  defp check_time({pos, vel}, new_pos) do
    {x0, _, _} = pos
    {dx, _, _} = vel
    {x1, _} = new_pos
    t = (x1 - x0) / dx
    t
  end

  defp build_equation([{pos_1, vel_1}, {pos_2, vel_2}]) do
    {x_1, y_1, z_1} = pos_1
    {dx_1, dy_1, dz_1} = vel_1
    {x_2, y_2, z_2} = pos_2
    {dx_2, dy_2, dz_2} = vel_2
    constant_xy = y_1 * dx_1 + x_2 * dy_2 - x_1 * dy_1 - y_2 * dx_2
    constant_xz = z_1 * dx_1 + x_2 * dz_2 - x_1 * dz_1 - z_2 * dx_2

    [
      [dy_2 - dy_1, dx_1 - dx_2, 0, y_1 - y_2, x_2 - x_1, 0, constant_xy],
      [dz_2 - dz_1, 0, dx_1 - dx_2, z_1 - z_2, 0, x_2 - x_1, constant_xz]
    ]
  end

  defp gaussian_elimination(matrix) do
    {rows, cols} = {Enum.count(matrix), Enum.count(Enum.at(matrix, 0))}
    gaussian_elimination(matrix, {0, rows}, {0, cols - 1})
  end

  defp gaussian_elimination(matrix, {rows, rows}, {cols, cols}), do: matrix

  defp gaussian_elimination(matrix, {pivot_row, rows}, {pivot_col, cols}) do
    {max, idx_max} =
      Enum.map(pivot_row..(rows - 1), fn row ->
        {matrix |> Enum.at(row) |> Enum.at(pivot_col), row}
      end)
      |> Enum.max()

    if max == 0 do
      gaussian_elimination(matrix, {pivot_row, rows}, {pivot_col + 1, cols})
    else
      swap_matrix =
        swap_rows(matrix, pivot_row, idx_max)

      gaussian_elimination(
        update_matrix(swap_matrix, pivot_row, pivot_col),
        {pivot_row + 1, rows},
        {pivot_col + 1, cols}
      )
    end
  end

  defp swap_rows(matrix, idx_1, idx_2) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn
      {row, ^idx_1} -> {row, idx_2}
      {row, ^idx_2} -> {row, idx_1}
      res -> res
    end)
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.map(fn {row, _} -> row end)
  end

  defp update_matrix(matrix, pivot_row, pivot_col) do
    for {row, row_idx} <- matrix |> Enum.with_index() do
      if row_idx > pivot_row do
        ratio = Enum.at(row, pivot_col) / (matrix |> Enum.at(pivot_row) |> Enum.at(pivot_col))

        for {el, col_idx} <- row |> Enum.with_index() do
          if col_idx == pivot_col do
            0.0
          else
            el - (Enum.at(matrix, pivot_row) |> Enum.at(col_idx)) * ratio
          end
        end
      else
        for el <- row do
          el
        end
      end
    end
  end

  defp solve(matrix) do
    rows = Enum.count(matrix)

    Enum.reverse(matrix)
    |> Enum.reduce(List.duplicate(0, rows), fn row, acc ->
      {coefs, const} = Enum.split(row, -1)
      diff = Enum.zip(coefs, acc) |> Enum.map(fn {coef, val} -> coef * val end) |> Enum.sum()
      den = Enum.find_index(coefs, &(&1 != 0))
      res = (hd(const) - diff) / Enum.at(coefs, den)
      List.replace_at(acc, den, res)
    end)
  end

  defp parse_pos_vel(line) do
    line
    |> String.split(~r/\s+@\s+/, trim: true)
    |> Enum.map(fn coords ->
      String.split(coords, ~r/,\s+/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end
end
