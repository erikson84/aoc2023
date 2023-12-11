defmodule AdventOfCode.DayTen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTen` for AoC '23.
  """
  def first_star(path) do
    {:ok, str} = File.read(path)

    str
    |> map_of_str()
    |> traverse_pipes()
    |> Enum.count()
    |> then(&div(&1 - 1, 2))
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
end
