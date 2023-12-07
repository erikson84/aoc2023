defmodule AdventOfCode.DaySix do
  @moduledoc """
  Implements solutions for the first and second star
  of `DaySix` for AoC '23.
  """
  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> get_time_and_record(:first)
    |> Enum.map(fn {max_time, record} ->
      all_distances(max_time)
      |> Enum.reject(&(&1 <= record))
      |> Enum.count()
    end)
    |> Enum.product()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> get_time_and_record(:second)
    |> count_records()
  end

  defp all_distances(max_time), do: 0..max_time |> Enum.map(&distance_of_time(&1, max_time))

  defp distance_of_time(time_holding, max_time) do
    (max_time - time_holding) * time_holding
  end

  defp count_records([max_time, record]) do
    first_bigger = Enum.find(0..max_time, fn num -> (max_time - num) * num > record end)
    max_time + 1 - 2 * first_bigger
  end

  defp get_time_and_record(str, star) do
    data =
      String.split(str, "\n", trim: true)
      |> Enum.map(fn line ->
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
      end)

    case star do
      :first ->
        Enum.map(data, fn line -> Enum.map(line, &String.to_integer/1) end) |> Enum.zip()

      :second ->
        Enum.map(data, &Enum.join/1) |> Enum.map(&String.to_integer/1)
    end
  end
end
