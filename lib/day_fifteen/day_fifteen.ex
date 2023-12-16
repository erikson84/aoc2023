defmodule AdventOfCode.DayFifteen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayFifteen` for AoC '23.
  """
  def first_star(path) do
    {:ok, string} = File.read(path)

    string
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, string} = File.read(path)

    string
    |> String.trim()
    |> String.split(",")
    |> Enum.reduce(%{}, fn step, acc ->
      %{label: label, op: op, number: num} = process_step(step)
      box = hash(Atom.to_string(label))

      case op do
        "-" ->
          Map.update(acc, box, [], fn lens -> Keyword.delete(lens, label) end)

        "=" ->
          Map.update(acc, box, [{label, num}], fn lens ->
            if Keyword.has_key?(lens, label) do
              Keyword.replace!(lens, label, num)
            else
              lens ++ [{label, num}]
            end
          end)
      end
    end)
    |> Enum.map(fn {box, lst} ->
      lst
      |> Enum.with_index(1)
      |> Enum.map(fn {{_label, num}, idx} -> num * idx * (box + 1) end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  defp hash(string, acc \\ 0)
  defp hash("", acc), do: acc
  defp hash(<<char, str::binary>>, acc), do: hash(str, rem((acc + char) * 17, 256))

  def process_step(str) do
    Regex.named_captures(~r/(?<label>[a-z]+)(?<op>\-|\=)(?<number>[0-9]*)/, str)
    |> Map.new(fn
      {"label", value} -> {:label, String.to_atom(value)}
      {"op", op} -> {:op, op}
      {"number", ""} -> {:number, nil}
      {"number", num} -> {:number, String.to_integer(num)}
    end)
  end
end
