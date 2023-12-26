defmodule AdventOfCode.DayFour do
  @moduledoc """
  Documentation for `DayFour`.
  """
  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.with_index(1)
    |> process_card(%{})
  end

  def first_star(path) do
    File.stream!(path)
    |> Stream.map(fn line ->
      line
      |> process_line()
      |> count_matches()
      |> case do
        0 -> 0
        n -> 2 ** (n - 1)
      end
    end)
    |> Enum.sum()
  end

  defp process_card([], acc), do: acc |> Map.values() |> Enum.sum()

  defp process_card([{str, idx} | cards], acc) do
    extra_cards =
      process_line(str)
      |> count_matches()

    acc_card = Map.update(acc, idx, 1, fn val -> val + 1 end)

    case extra_cards do
      0 ->
        process_card(cards, acc_card)

      num ->
        (idx + 1)..(idx + num)
        |> Enum.reduce(acc_card, fn card, acc ->
          Map.update(acc, card, acc_card[idx], fn val -> val + acc_card[idx] end)
        end)
        |> then(&process_card(cards, &1))
    end
  end

  defp process_line(str) do
    str
    |> String.replace(~r/^Card\s+[0-9]+:\s+/, "")
    |> String.split(" | ")
    |> Enum.map(&String.split(&1, ~r/\s+/, trim: true))
  end

  defp count_matches([cards, win_numbers]) do
    Enum.filter(cards, fn card -> card in win_numbers end) |> Enum.count()
  end
end
