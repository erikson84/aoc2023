defmodule AdventOfCode.DayEleven do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayEleven` for AoC '23.
  """

  @exp_const 1_000_000 - 1
  def first_star(path) do
    {:ok, str} = File.read(path)

    str
    |> matrixify()
    |> expand_lines()
    |> get_galaxies()
    |> all_pairs()
    |> Enum.map(&manhattan_dist/1)
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    matrix = matrixify(str)
    galaxies = get_galaxies(matrix)
    row_factors = expansion_factor(matrix)
    col_factors = expansion_factor(transpose(matrix))

    all_pairs(galaxies)
    |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
      manhattan_dist({
        {x1 + Enum.at(row_factors, x1) * @exp_const, y1 + Enum.at(col_factors, y1) * @exp_const},
        {x2 + Enum.at(row_factors, x2) * @exp_const, y2 + Enum.at(col_factors, y2) * @exp_const}
      })
    end)
    |> Enum.sum()
  end

  defp matrixify(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp transpose(matrix) do
    Enum.zip_with(matrix, & &1)
  end

  defp expand_lines(matrix) do
    expand_rows(matrix, [])
    |> transpose()
    |> expand_rows([])
    |> transpose()
  end

  defp expansion_factor(lines), do: expansion_factor(lines, [0])
  defp expansion_factor([], acc), do: Enum.reverse(acc) |> tl()

  defp expansion_factor([line | lines], [factor | acc]) do
    if Enum.all?(line, &(&1 == ".")) do
      expansion_factor(lines, [factor + 1, factor | acc])
    else
      expansion_factor(lines, [factor, factor | acc])
    end
  end

  defp expand_rows([], acc), do: Enum.reverse(acc)

  defp expand_rows([row | rows], acc) do
    if Enum.all?(row, &(&1 == ".")) do
      expand_rows(rows, [row, row | acc])
    else
      expand_rows(rows, [row | acc])
    end
  end

  defp get_galaxies(map) do
    {rows, cols} = {Enum.count(map), Enum.count(Enum.at(map, 0))}

    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        Enum.at(map, r) |> Enum.at(c) != "." do
      {r, c}
    end
  end

  defp all_pairs(lst, acc \\ [])
  defp all_pairs([], acc), do: acc

  defp all_pairs([fst | rest], acc) do
    all_pairs(rest, Enum.map(rest, &{fst, &1}) ++ acc)
  end

  defp manhattan_dist({{x1, y1}, {x2, y2}}), do: abs(x1 - x2) + abs(y1 - y2)
end
