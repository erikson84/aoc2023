defmodule AdventOfCode.DayTwelve do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwelve` for AoC '23.

  Algorithm based on the dynamic solution in 
  https://github.com/clrfl/AdventOfCode2023/blob/master/12/part1.py
  """
  def first_star(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      {string, counts} =
        line
        |> process_line()

      matches(string, counts)
    end)
    |> Enum.sum()
  end

  def second_star(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      {string, counts} =
        line
        |> process_line()

      matches(
        List.duplicate(string, 5) |> Enum.join("?"),
        List.duplicate(counts, 5) |> List.flatten()
      )
    end)
    |> Enum.sum()
  end

  defp process_line(line) do
    [string, counts] =
      line
      |> String.trim()
      |> String.split(~r/\s+/)

    {string, counts |> String.split(",") |> Enum.map(&String.to_integer/1)}
  end

  defp matches(string, counts) do
    states =
      Enum.map(counts, fn num -> String.duplicate("#", num) end)
      |> Enum.join(".")
      |> then(&".#{&1}.")
      |> String.graphemes()

    matches(string, states, %{0 => 1})
  end

  defp matches("", states, acc),
    do: Map.get(acc, length(states) - 1, 0) + Map.get(acc, length(states) - 2, 0)

  defp matches("?" <> string, states, acc) do
    Enum.reduce(acc, %{}, fn
      {state, cont}, new_acc ->
        new_acc
        |> then(fn new_acc ->
          if state + 1 < length(states),
            do: Map.update(new_acc, state + 1, cont, &(&1 + cont)),
            else: new_acc
        end)
        |> then(fn new_acc ->
          if Enum.at(states, state) == ".",
            do: Map.update(new_acc, state, cont, &(&1 + acc[state])),
            else: new_acc
        end)
    end)
    |> then(&matches(string, states, &1))
  end

  defp matches("." <> string, states, acc) do
    Enum.reduce(acc, %{}, fn
      {state, cont}, new_acc ->
        new_acc
        |> then(fn new_acc ->
          if state + 1 < length(states) and Enum.at(states, state + 1) == ".",
            do: Map.update(new_acc, state + 1, cont, &(&1 + cont)),
            else: new_acc
        end)
        |> then(fn new_acc ->
          if Enum.at(states, state) == ".",
            do: Map.update(new_acc, state, cont, &(&1 + acc[state])),
            else: new_acc
        end)
    end)
    |> then(&matches(string, states, &1))
  end

  defp matches("#" <> string, states, acc) do
    Enum.reduce(acc, %{}, fn
      {state, cont}, new_acc ->
        if state + 1 < length(states) and Enum.at(states, state + 1) == "#",
          do: Map.update(new_acc, state + 1, cont, &(&1 + cont)),
          else: new_acc
    end)
    |> then(&matches(string, states, &1))
  end
end
