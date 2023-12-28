defmodule AdventOfCode.DayTwentyFour do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyFour` for AoC '23.
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
