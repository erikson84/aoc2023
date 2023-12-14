defmodule AdventOfCode.DayThirteen do
  @moduledoc """
    Implements solutions for the first and second star
    of `DayTwelve` for AoC '23.
  """
  def first_star(path) do
    {:ok, raw_map} = File.read(path)

    raw_map
    |> process_map()
    |> Enum.map(&find_mirror(&1))
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, raw_map} = File.read(path)

    raw_map
    |> process_map()
    |> Enum.map(&find_mirror_with_smudge/1)
    |> IO.inspect()
    |> Enum.sum()
  end

  defp find_mirror(map) do
    if num = Enum.find(1..(length(map) - 1), &compare(map, &1)) do
      100 * num
    else
      trans_map = transpose(map)
      Enum.find(1..(length(trans_map) - 1), &compare(trans_map, &1))
    end
  end

  defp find_mirror_with_smudge(map) do
    equal_with_smudge =
      for {line, idx1} <- Enum.with_index(map, 1),
          {other_line, idx2} <- Enum.with_index(map, 1),
          idx1 < idx2,
          rem(idx2 - idx1, 2) == 1,
          distance(line, other_line, 0) == 1 do
        {idx1, idx2}
      end

    if num =
         Enum.find(equal_with_smudge, fn {idx1, idx2} ->
           map
           |> List.replace_at(idx1 - 1, Enum.at(map, idx2 - 1))
           |> compare(idx1 + div(idx2 - idx1, 2))
         end) do
      {idx1, idx2} = num
      100 * (idx1 + div(idx2 - idx1, 2))
    else
      div(find_mirror_with_smudge(transpose(map)), 100)
    end
  end

  defp compare(map, line_number) do
    {line_before, line_after} = Enum.split(map, line_number)
    compare_lines(Enum.reverse(line_before), line_after)
  end

  defp compare_lines([], _), do: true
  defp compare_lines(_, []), do: true

  defp compare_lines([line_before | lines_before], [line_after | lines_after])
       when line_before == line_after,
       do: compare_lines(lines_before, lines_after)

  defp compare_lines(_, _), do: false

  def transpose(map) do
    map |> Enum.map(&String.graphemes/1) |> Enum.zip_with(& &1) |> Enum.map(&Enum.join/1)
  end

  defp process_map(raw_map) do
    raw_map |> String.split("\n\n", trim: true) |> Enum.map(&String.split(&1, "\n", trim: true))
  end

  defp distance("", _, acc), do: acc

  defp distance(<<fst, str1::binary>>, <<snd, str2::binary>>, acc) when fst == snd do
    distance(str1, str2, acc)
  end

  defp distance(<<_, str1::binary>>, <<_, str2::binary>>, acc) do
    distance(str1, str2, acc + 1)
  end
end
