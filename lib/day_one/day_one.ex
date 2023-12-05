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
    |> Stream.map(fn line ->
      fst = Regex.run(~r/[0-9]/, line) |> Enum.at(0)
      lst = Regex.run(~r/[0-9]/, String.reverse(line)) |> Enum.at(0)

      String.to_integer(fst <> lst)
    end)
    |> Enum.sum()
  end

  def second_star(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      line
      |> get_first_and_last()
      |> Enum.join()
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  defp get_first_and_last(str) do
    fst = Regex.run(~r/([0-9]|#{Map.keys(@numbers) |> Enum.join("|")})/, str) |> Enum.at(1)

    lst =
      Regex.run(
        ~r/([0-9]|#{Map.keys(@numbers) |> Enum.join("|") |> String.reverse()})/,
        String.reverse(str)
      )
      |> Enum.at(1)
      |> String.reverse()

    [@numbers[fst] || fst, @numbers[lst] || lst]
  end
end
