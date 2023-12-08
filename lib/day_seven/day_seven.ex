defmodule AdventOfCode.DaySeven do
  @moduledoc """
  Implements solutions for the first and second star
  of `DaySeven` for AoC '23.
  """
  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> get_hands_and_bids()
    |> parse_numbers(:first)
    |> Enum.sort_by(fn {hand, _} -> evaluate_hand(hand) end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bid}, order} -> order * bid end)
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> get_hands_and_bids()
    |> parse_numbers(:second)
    |> Enum.sort_by(fn {hand, _} -> evaluate_hand(hand) end)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bid}, order} -> order * bid end)
    |> Enum.sum()
  end

  defp evaluate_hand(hand) do
    opt_hand = optimize_hand(hand)

    case Enum.sort_by(opt_hand, fn card -> {Enum.count(opt_hand, &(&1 == card)), card} end, :desc) do
      [c, c, c, c, c] -> {6, hand}
      [c, c, c, c, _] -> {5, hand}
      [c, c, c, d, d] -> {4, hand}
      [c, c, c, _, _] -> {3, hand}
      [c, c, d, d, _] -> {2, hand}
      [c, c, _, _, _] -> {1, hand}
      [_, _, _, _, _] -> {0, hand}
    end
  end

  defp optimize_hand(hand) do
    most_freq =
      hand
      |> Enum.reject(&(&1 == 1))
      |> Enum.max_by(fn card -> Enum.count(hand, &(&1 == card)) end, fn -> 1 end)

    Enum.map(
      hand,
      fn
        1 -> most_freq
        num -> num
      end
    )
  end

  defp get_hands_and_bids(str) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, ~r/\s+/, trim: true) |> List.to_tuple() end)
    |> Enum.unzip()
  end

  defp parse_numbers({hands, bids}, star) do
    [
      hands
      |> Enum.map(fn hand -> String.graphemes(hand) |> Enum.map(&value_of_card(&1, star)) end),
      bids |> Enum.map(&String.to_integer/1)
    ]
    |> Enum.zip()
  end

  defp value_of_card(card, star) do
    case card do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" when star == :first -> 11
      "J" -> 1
      "T" -> 10
      num -> String.to_integer(num)
    end
  end
end
