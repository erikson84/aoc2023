defmodule AdventOfCode do
  @moduledoc """
  Implements a basic CLI to reproduce the results of my solutions
  to the `Advent of Code '23`.
  """
  @modules %{
    1 => AdventOfCode.DayOne,
    2 => AdventOfCode.DayTwo,
    3 => AdventOfCode.DayThree,
    4 => DayFour,
    5 => DayFive
  }
  @stars %{
    1 => :first_star,
    2 => :second_star
  }
  @files %{
    1 => "day_one.txt",
    2 => "day_two.txt",
    3 => "day_three.txt",
    4 => "day_four.txt",
    5 => "day_five.txt"
  }
  def main(args \\ []) do
    args
    |> parse_args()
    |> run_code()
    |> IO.puts()
  end

  defp parse_args(args) do
    {res, _, _} =
      args
      |> OptionParser.parse(strict: [day: :integer, star: :integer])

    case res do
      [] ->
        {:error, "Usage: --day \\d+ --star (1|2)"}

      [day: _, star: star] when star not in 1..2 ->
        {:error, "--star argument must be either 1 or 2."}

      [day: day, star: _] when day not in 1..24 ->
        {:error, "--day argument must be between 1 and 24."}

      res = [day: _, star: _] ->
        {:ok, res}

      [day: _] ->
        {:error, "Must specify --star argument with value 1 or 2."}

      [star: _] ->
        {:error, "Must specify --day argument with value between 1 and 24."}
    end
  end

  defp run_code({:error, msg}), do: msg

  defp run_code({:ok, [day: day, star: star]}) do
    res = apply(@modules[day], @stars[star], ["./input/" <> @files[day]])

    "Results for advent day #{day}, #{@stars[star] |> Atom.to_string() |> String.replace("_", " ")}: #{res}."
  end
end
