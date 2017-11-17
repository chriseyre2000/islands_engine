defmodule IslandsTest do
  use ExUnit.Case

  alias IslandsEngine.{Board, Coordinate, Island}

  test "Single dot island wins" do
    board = Board.new()
    {:ok, dot_coordinate} = Coordinate.new(2, 2)
    {:ok, dot} = Island.new(:dot, dot_coordinate)
    board = Board.position_island(board, :dot, dot)
    {:hit, :dot, :win, _board} = Board.guess(board, dot_coordinate)
  end 

  test "can't add overlapping_island" do
    board = Board.new()

    {:ok, square_coordinate} = Coordinate.new(1, 1)

    {:ok, square} = Island.new(:square, square_coordinate)

    board = Board.position_island(board, :square, square)

    {:ok, dot_coordinate} = Coordinate.new(2, 2)

    {:ok, dot} = Island.new(:dot, dot_coordinate)

    #Fails to add an overlapping island
    {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
  end


  test "hit, miss, cheat and win" do
    board = Board.new()

    {:ok, square_coordinate} = Coordinate.new(1, 1)

    {:ok, square} = Island.new(:square, square_coordinate)

    board = Board.position_island(board, :square, square)

    {:ok, dot_coordinate} = Coordinate.new(3, 3)

    {:ok, dot} = Island.new(:dot, dot_coordinate)

    board = Board.position_island(board, :dot, dot)
    
    {:ok, guess_coordinate} = Coordinate.new(10, 10)

    #Wild guess misses
    {:miss, :none, :no_win, board} = Board.guess(board, guess_coordinate)

    {:ok, hit_coordinate} = Coordinate.new(1, 1)

    #First hit 
    {:hit, :none, :no_win, board} = Board.guess(board, hit_coordinate)

    #Cheat the rest of the square island
    square = %{square | hit_coordinates: square.coordinates}

    board = Board.position_island(board, :square, square)

    {:ok, win_coordinate} = Coordinate.new(3, 3)
    {:hit, :dot, :win, _board} = Board.guess(board, win_coordinate)

  end

end
