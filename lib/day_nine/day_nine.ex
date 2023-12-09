defmodule AdventOfCode.DayNine do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayNine` for AoC '23.
  """

  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(~r/\s+/)
      |> Enum.map(&String.to_integer/1)
      |> find_equal_seq()
      |> predict_next()
    end)
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(~r/\s+/)
      |> Enum.map(&String.to_integer/1)
      |> find_equal_seq()
      |> predict_prev()
    end)
    |> Enum.sum()
  end

  defp predict_next(seqs), do: predict_next(seqs, 0)
  defp predict_next([], acc), do: acc

  defp predict_next([next | rest], acc) do
    predict_next(rest, acc + List.last(next))
  end

  defp predict_prev(seqs), do: predict_prev(seqs, 0)
  defp predict_prev([], acc), do: acc

  defp predict_prev([next | rest], acc) do
    predict_prev(rest, hd(next) - acc)
  end

  defp find_equal_seq(seq), do: find_equal_seq(seq, [])

  defp find_equal_seq(seq, acc) do
    if Enum.all?(seq, &(&1 == 0)) do
      acc
    else
      find_equal_seq(reduce_seq(seq, []), [seq | acc])
    end
  end

  defp reduce_seq([fst, sec], acc), do: Enum.reverse([sec - fst | acc])

  defp reduce_seq([fst, sec | rest], acc) do
    reduce_seq([sec | rest], [sec - fst | acc])
  end
end
