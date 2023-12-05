defmodule AdventOfCode.DayOne do
  @numbers %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def first_star(path) do
    File.stream!(path)
    |> Stream.map(&get_first_and_last(&1, :first))
    |> Enum.sum()
  end

  def second_star(path) do
    File.stream!(path)
    |> Stream.map(&get_first_and_last(&1, :second))
    |> Enum.sum()
  end

  defp get_first_and_last(line, :first) do
    fst = Regex.run(~r/[0-9]/, line) |> Enum.at(0)
    lst = Regex.run(~r/[0-9]/, String.reverse(line)) |> Enum.at(0)

    String.to_integer(fst <> lst)
  end

  defp get_first_and_last(line, :second) do
    fst = Regex.run(~r/([0-9]|#{Map.keys(@numbers) |> Enum.join("|")})/, line) |> Enum.at(1)

    lst =
      Regex.run(
        ~r/([0-9]|#{Map.keys(@numbers) |> Enum.join("|") |> String.reverse()})/,
        String.reverse(line)
      )
      |> Enum.at(1)
      |> String.reverse()

    ((@numbers[fst] || fst) <> (@numbers[lst] || lst))
    |> String.to_integer()
  end
end
