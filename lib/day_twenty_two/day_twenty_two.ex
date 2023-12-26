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
        desintegrated_blocks == mark_supported(desintegrated_blocks, []) do
      block
    end
  end

  defp check_chain(blocks) do
    for block <- blocks,
        desintegrated_blocks = blocks -- [block] do
      Enum.count(mark_supported(desintegrated_blocks, []), fn block ->
        not Enum.member?(desintegrated_blocks, block)
      end)
    end
  end

  defp mark_supported(blocks) do
    blocks =
      Enum.map(blocks, fn {block, idx} -> {expand_block(block), idx} end)
      |> Enum.sort_by(fn {list, _idx} ->
        Enum.min(Enum.map(list, fn {x, y, z} -> {z, y, x} end))
      end)

    mark_supported(blocks, [])
  end

  defp mark_supported([], acc),
    do:
      Enum.sort_by(acc, fn {list, _idx} ->
        Enum.min(Enum.map(list, fn {x, y, z} -> {z, y, x} end))
      end)

  defp mark_supported([{block, idx} | blocks], acc) do
    if Enum.any?(block, fn {_x, _y, z} -> z == 1 end) do
      mark_supported(blocks, [{block, idx} | acc])
    else
      step_down =
        Enum.map(block, fn {x, y, z} -> {x, y, z - 1} end)

      if Enum.any?(step_down, fn coord ->
           Enum.any?(List.flatten(Enum.map(acc, fn {list, _} -> list end)), fn sup_coord ->
             sup_coord == coord
           end)
         end) do
        mark_supported(blocks, [{block, idx} | acc])
      else
        mark_supported([{step_down, idx} | blocks], acc)
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
