defmodule AdventOfCode.DayFourteen do
  @moduledoc """
    Implements solutions for the first and second star
    of `DayTwelve` for AoC '23. 
  """
  @max_iter 1_000
  @max_cycles 1_000_000_000

  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> count_stones()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> then(
      &Enum.reduce_while(1..@max_iter, [&1], fn _, [last | rest] ->
        if Enum.member?(rest, last) do
          list = Enum.reverse(rest)
          first_idx = Enum.find_index(list, fn el -> el == last end)
          last_idx = length(list) - 1
          cycle_length = last_idx - first_idx + 1
          {:halt, Enum.at(list, first_idx + rem(@max_cycles - first_idx, cycle_length))}
        else
          {:cont, [cycle(last), last | rest]}
        end
      end)
    )

    # |> elem(0)
    |> count_stones()
  end

  defp move_line(string, direction) do
    Regex.scan(~r/(?:[^\#]+|\#+)/, string)
    |> Enum.map(fn
      [str = "#" <> _rest] -> str
      [str] when direction == :up -> String.graphemes(str) |> Enum.sort(:desc)
      [str] when direction == :down -> String.graphemes(str) |> Enum.sort()
    end)
    |> Enum.join()
  end

  defp count_stones(map) do
    map
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.map(fn {str, idx} ->
      String.graphemes(str) |> Enum.count(&(&1 == "O")) |> then(&(&1 * idx))
    end)
    |> Enum.sum()
  end

  defp transpose(map) do
    Enum.map(map, &String.graphemes/1)
    |> Enum.zip_with(& &1)
    |> Enum.map(&Enum.join/1)
  end

  defp cycle(map) do
    map
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> Enum.map(&move_line(&1, :up))
    |> transpose()
    |> Enum.map(&move_line(&1, :down))
    |> transpose()
    |> Enum.map(&move_line(&1, :down))
  end
end
