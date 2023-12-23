defmodule AdventOfCode do
  @moduledoc """
  Implements a basic CLI to reproduce the results of my solutions
  to the `Advent of Code '23`.
  """
  @modules %{
    1 => AdventOfCode.DayOne,
    2 => AdventOfCode.DayTwo,
    3 => AdventOfCode.DayThree,
    4 => AdventOfCode.DayFour,
    5 => AdventOfCode.DayFive,
    6 => AdventOfCode.DaySix,
    7 => AdventOfCode.DaySeven,
    8 => AdventOfCode.DayEight,
    9 => AdventOfCode.DayNine,
    10 => AdventOfCode.DayTen,
    11 => AdventOfCode.DayEleven,
    12 => AdventOfCode.DayTwelve,
    13 => AdventOfCode.DayThirteen,
    14 => AdventOfCode.DayFourteen,
    15 => AdventOfCode.DayFifteen,
    16 => AdventOfCode.DaySixteen,
    17 => AdventOfCode.DaySeventeen,
    18 => AdventOfCode.DayEighteen,
    19 => AdventOfCode.DayNineteen,
    20 => AdventOfCode.DayTwenty
  }
  @stars %{
    1 => :first_star,
    2 => :second_star
  }

  def main(args \\ []) do
    args
    |> parse_args()
    |> run_code()
    |> IO.puts()
  end

  defp parse_args(args) do
    {res, file, _} =
      args
      |> OptionParser.parse(strict: [day: :integer, star: :integer])

    case {Enum.sort(res), file} do
      {[], []} ->
        {:error, "Usage: --day \\d+ --star (1|2) path/to/file"}

      {[day: _, star: star], _file} when star not in 1..2 ->
        {:error, "--star argument must be either 1 or 2."}

      {[day: day, star: _], _file} when day not in 1..25 ->
        {:error, "--day argument must be between 1 and 25."}

      {[day: _], _file} ->
        {:error, "Must specify --star argument with value 1 or 2."}

      {[star: _], _file} ->
        {:error, "Must specify --day argument with value between 1 and 24."}

      res = {[day: _, star: _], file} ->
        if file == [] or not File.exists?(file) do
          {:error, "You must specify a valid path to the input file."}
        else
          {:ok, res}
        end
    end
  end

  defp run_code({:error, msg}), do: msg

  defp run_code({:ok, {[day: day, star: star], file}}) do
    res = apply(@modules[day], @stars[star], [file])

    "Results for advent day #{day}, #{@stars[star] |> Atom.to_string() |> String.replace("_", " ")}: #{res}."
  end
end
