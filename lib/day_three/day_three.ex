defmodule DayThree do
  @moduledoc """
  Documentation for `DayThree`.
  """
  def search_engines(path) do
    {:ok, board} = File.read(path)

    fun_board = to_board(board)

    fun_board
    |> get_symbols()
    |> Enum.map(fn pos ->
      get_neighbors(fun_board, pos)
      |> Enum.filter(fn {neighbor, _idx} -> neighbor =~ ~r/[0-9]/ end)
      |> Enum.map(fn {_num, idx} -> get_number(fun_board, idx) |> String.to_integer() end)
      |> Enum.uniq()
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def search_true_engines(path) do
    {:ok, board} = File.read(path)

    fun_board = to_board(board)

    fun_board
    |> get_gears()
    |> Enum.map(fn pos ->
      get_neighbors(fun_board, pos)
      |> Enum.filter(fn {neighbor, _idx} -> neighbor =~ ~r/[0-9]/ end)
      |> Enum.map(fn {_num, idx} -> get_number(fun_board, idx) |> String.to_integer() end)
      |> Enum.uniq()
      |> then(&if(length(&1) == 2, do: Enum.product(&1), else: 0))
    end)
    |> Enum.sum()
  end

  defp to_board(board) do
    all_rows = matrixify(board)
    {rows, cols} = {length(all_rows), length(Enum.at(all_rows, 0))}

    fn
      {:dims} -> {rows, cols}
      {:get, {row, col}} -> all_rows |> Enum.at(row) |> Enum.at(col)
    end
  end

  defp matrixify(board) do
    board
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  defp get_neighbors(board, {row, col}) do
    {rows, cols} = board.({:dims})

    for {r, c} <- [
          {row - 1, col - 1},
          {row - 1, col},
          {row, col - 1},
          {row + 1, col + 1},
          {row + 1, col},
          {row, col + 1},
          {row + 1, col - 1},
          {row - 1, col + 1}
        ],
        r in 0..rows,
        c in 0..cols do
      {board.({:get, {r, c}}), {r, c}}
    end
  end

  defp get_symbols(board) do
    {rows, cols} = board.({:dims})

    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        board.({:get, {r, c}}) =~ ~r/[^0-9.]/ do
      {r, c}
    end
  end

  defp get_gears(board) do
    {rows, cols} = board.({:dims})

    for r <- 0..(rows - 1),
        c <- 0..(cols - 1),
        board.({:get, {r, c}}) == "*" do
      {r, c}
    end
  end

  defp get_number(board, {row, col}) do
    search_back(board, {row, col - 1}) <>
      board.({:get, {row, col}}) <> search_forward(board, {row, col + 1})
  end

  defp search_forward(board, {row, col}) do
    {_rows, cols} = board.({:dims})

    cond do
      col == cols ->
        ""

      board.({:get, {row, col}}) =~ ~r/[0-9]/ ->
        board.({:get, {row, col}}) <> search_forward(board, {row, col + 1})

      true ->
        ""
    end
  end

  defp search_back(board, {row, col}) do
    cond do
      col < 0 ->
        ""

      board.({:get, {row, col}}) =~ ~r/[0-9]/ ->
        search_back(board, {row, col - 1}) <> board.({:get, {row, col}})

      true ->
        ""
    end
  end
end
