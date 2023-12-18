defmodule AdventOfCode.DayEighteen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayEighteen` for AoC '23.
  """
  def first_star(path) do
    File.stream!(path)
    |> Enum.map(&process_line/1)
    |> dig_ditch([{0, 0}])
    |> total_area()
  end

  def second_star(path) do
    File.stream!(path)
    |> Enum.map(&process_code/1)
    |> dig_ditch([{0, 0}])
    |> total_area()
  end

  defp dig_ditch([], acc), do: acc

  defp dig_ditch([next_step | rest], [prev_pos | acc]) do
    dig_ditch(rest, [step(prev_pos, next_step), prev_pos | acc])
  end

  defp step({x, y}, {direction, size}) do
    case direction do
      "U" -> {x + size, y}
      "D" -> {x - size, y}
      "L" -> {x, y - size}
      "R" -> {x, y + size}
    end
  end

  defp total_area(coords) do
    b = perimeter(coords, 0)
    area = shoelace(coords, 0)
    i = area - div(b, 2) + 1

    b + i
  end

  defp shoelace([_], acc) when acc < 0, do: div(-acc, 2)
  defp shoelace([_], acc), do: div(acc, 2)

  defp shoelace([{x1, y1}, snd = {x2, y2} | rest], acc) do
    shoelace([snd | rest], acc + (x1 * y2 - y1 * x2))
  end

  defp perimeter([_], acc), do: acc

  defp perimeter([{x1, y1}, snd = {x2, y2} | rest], acc) do
    perimeter([snd | rest], acc + abs(x1 - x2) + abs(y1 - y2))
  end

  defp process_line(line) do
    [direction, size] =
      line
      |> String.trim()
      |> String.split(~r/\s+/)
      |> Enum.take(2)

    {direction, String.to_integer(size)}
  end

  defp process_code(line) do
    code =
      line
      |> String.trim()
      |> String.split(~r/\s+/)
      |> List.last()

    [[_, size, direction]] = Regex.scan(~r/\#([abcdef0-9]{5})([0-3])/, code)

    direction =
      case direction do
        "0" -> "R"
        "1" -> "D"
        "2" -> "L"
        "3" -> "U"
      end

    {direction, String.to_integer(size, 16)}
  end
end
