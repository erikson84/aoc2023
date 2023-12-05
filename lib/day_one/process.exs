defmodule DayOne do
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

  def call do
    case System.argv() do
      [] -> IO.puts("You must specify an input file.")
      [path] -> process_input(path) |> IO.puts()
      _ -> IO.puts("You must specify *ONLY* a file.")
    end
  end

  def process_input(path) do
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

DayOne.call()
