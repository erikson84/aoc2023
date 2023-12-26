defmodule AdventOfCode.DayTwentyTwo do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwentyTwo` for AoC '23.
  """
  @type coord :: {non_neg_integer(), non_neg_integer(), non_neg_integer()}
  @type block :: {coord, coord}

  def first_star(path) do
    {:ok, str} = File.read(path)

    str
    |> String.split("\n", trim: true)
    |> Enum.map(&process_line/1)
    |> Enum.with_index()
    |> mark_supported()
    |> check_desintegrate()
    |> Enum.count()
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    str
    |> String.split("\n", trim: true)
    |> Enum.map(&process_line/1)
    |> Enum.with_index()
    |> mark_supported()
    |> check_chain()
    |> Enum.sum()
  end

  defp check_desintegrate(blocks) do
    for block <- blocks,
        desintegrated_blocks = blocks -- [block],
        desintegrated_blocks == mark_supported(desintegrated_blocks, MapSet.new(), []) do
      block
    end
  end

  defp check_chain(blocks) do
    for block <- blocks,
        desintegrated_blocks = blocks -- [block] do
      Enum.count(mark_supported(desintegrated_blocks, MapSet.new(), []), fn block ->
        not Enum.member?(desintegrated_blocks, block)
      end)
    end
  end

  defp mark_supported(blocks) do
    blocks
    |> Enum.sort_by(fn {{{x, y, z}, _}, _idx} -> {z, y, x} end)
    |> mark_supported(MapSet.new(), [])
  end

  defp mark_supported([], _, acc),
    do: acc |> Enum.sort_by(fn {{{x, y, z}, _}, _idx} -> {z, y, x} end)

  defp mark_supported([{block = {{x1, y1, z1}, {x2, y2, z2}}, idx} | blocks], supported, acc) do
    if z1 == 1 do
      mark_supported(
        blocks,
        Enum.reduce(expand_block(block), supported, fn coord, acc -> MapSet.put(acc, coord) end),
        [{block, idx} | acc]
      )
    else
      step_down = {{x1, y1, z1 - 1}, {x2, y2, z2 - 1}}

      if Enum.any?(expand_block(step_down), fn coord -> coord in supported end) do
        mark_supported(
          blocks,
          Enum.reduce(expand_block(block), supported, fn coord, acc -> MapSet.put(acc, coord) end),
          [{block, idx} | acc]
        )
      else
        mark_supported([{step_down, idx} | blocks], supported, acc)
      end
    end
  end

  defp expand_block({{x1, y1, z1}, {x2, y2, z2}}) do
    for x <- x1..x2,
        y <- y1..y2,
        z <- z1..z2 do
      {x, y, z}
    end
  end

  @spec process_line(String.t()) :: block()
  defp process_line(line) do
    line
    |> String.split("~")
    |> Enum.map(fn nums ->
      String.split(nums, ",", trim: true) |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
    |> List.to_tuple()
  end
end
