defmodule AdventOfCode.DayTen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTen` for AoC '23.
  """

  @doc """
  Solve the first challenge by traversing the pipes following
  each junction neccessary direction, considering the previous step.
  Finally, count the number of cells (minus one, since the start cell
  is counted twice) and divide by two to find the farthest cell number.
  """
  def first_star(path) do
    {:ok, str} = File.read(path)

    str
    |> map_of_str()
    |> traverse_pipes()
    |> Enum.count()
    |> then(&div(&1 - 1, 2))
  end

  @doc """
  From the cell path obtained from the first challenge, apply the shoelace
  algorithm to find the area enclosed by the pipes then apply Pick's theorem
  to relate the area to the inner points:

  $A = i + b/2 - 1$
  """
  def second_star(path) do
    {:ok, str} = File.read(path)

    boundaries =
      str
      |> map_of_str()
      |> traverse_pipes()

    area = shoelace_area(boundaries, 0)
    b = Enum.count(boundaries) - 1
    area - div(b, 2) + 1
  end

  defp map_of_str(str) do
    map = matrixify(str)
    {rows, cols} = {Enum.count(map), Enum.count(Enum.at(map, 0))}

    start =
      Enum.find_value(map |> Enum.with_index(), fn {row, r} ->
        if "S" in row, do: {r, Enum.find_index(row, &(&1 == "S"))}
      end)

    fn
      {:dims} ->
        {rows, cols}

      {:at, {row, col}} ->
        {map |> Enum.at(row) |> Enum.at(col), {row, col}}

      {:start} ->
        {"S", start}

      {:neighbors, {row, col}} ->
        for {n_row, n_col} <- [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}],
            n_row in 0..(rows - 1) and n_col in 0..(cols - 1) do
          {map |> Enum.at(n_row) |> Enum.at(n_col), {n_row, n_col}}
        end
    end
  end

  defp matrixify(str) do
    String.split(str, "\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp traverse_pipes(map) do
    traverse_pipes(map, [map.({:start})])
  end

  defp traverse_pipes(_map, acc = [{"S", _idx} | rest]) when length(rest) > 0, do: acc

  defp traverse_pipes(map, acc = [{"S", {row, col}}]) do
    step =
      hd(
        map.({:neighbors, {row, col}})
        |> Enum.filter(fn {char, _} -> char != "." end)
      )

    traverse_pipes(map, [step | acc])
  end

  defp traverse_pipes(map, acc = [{"|", {row, col}}, {_, {row_prev, _}} | _]) do
    if row_prev > row do
      traverse_pipes(map, [map.({:at, {row - 1, col}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row + 1, col}}) | acc])
    end
  end

  defp traverse_pipes(map, acc = [{"-", {row, col}}, {_, {_, col_prev}} | _]) do
    if col_prev > col do
      traverse_pipes(map, [map.({:at, {row, col - 1}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row, col + 1}}) | acc])
    end
  end

  defp traverse_pipes(map, acc = [{"L", {row, col}}, {_, {_, col_prev}} | _]) do
    if col_prev > col do
      traverse_pipes(map, [map.({:at, {row - 1, col}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row, col + 1}}) | acc])
    end
  end

  defp traverse_pipes(map, acc = [{"J", {row, col}}, {_, {_, col_prev}} | _]) do
    if col_prev < col do
      traverse_pipes(map, [map.({:at, {row - 1, col}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row, col - 1}}) | acc])
    end
  end

  defp traverse_pipes(map, acc = [{"7", {row, col}}, {_, {_, col_prev}} | _]) do
    if col_prev < col do
      traverse_pipes(map, [map.({:at, {row + 1, col}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row, col - 1}}) | acc])
    end
  end

  defp traverse_pipes(map, acc = [{"F", {row, col}}, {_, {_, col_prev}} | _]) do
    if col_prev > col do
      traverse_pipes(map, [map.({:at, {row + 1, col}}) | acc])
    else
      traverse_pipes(map, [map.({:at, {row, col + 1}}) | acc])
    end
  end

  defp shoelace_area([_], acc), do: if(acc < 0, do: div(-acc, 2), else: div(acc, 2))

  defp shoelace_area([{_, {r1, c1}}, nxt = {_, {r2, c2}} | rest], acc) do
    shoelace_area([nxt | rest], acc + (r1 * c2 - r2 * c1))
  end
end
