defmodule IslandsEngine.RulesTest do
  use ExUnit.Case

  alias IslandsEngine.Rules

  test "initialize" do
    rules = Rules.new()
    assert rules.state == :initialized
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set
  end

  test "add_player" do
    rules = Rules.new()
    {:ok, rules} = Rules.check(rules, :add_player)
    assert rules.state == :players_set
  end

  test "bad action" do
    rules = Rules.new()
    :error = Rules.check(rules, :completely_wrong_action)
    assert rules.state == :initialized
  end

  test "given player is set state is players_set" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}
    assert rules.state == :players_set
  end

  test "May not position islands until players set" do
    rules = Rules.new()
    :error = Rules.check(rules, {:position_islands, :player1})
  end

  test "Setting players islands does not change the state" do
    rules = Rules.new()
    rules = %{rules | state: :players_set}

    {:ok, rules} = Rules.check(rules, {:position_islands, :player1})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set
    
    {:ok, rules} = Rules.check(rules, {:position_islands, :player2})
    assert rules.state == :players_set
    assert rules.player1 == :islands_not_set
    assert rules.player2 == :islands_not_set
  end

  #TODO: Split this into sensible tests
  test "Player 1 can't change island once set" do
     rules = Rules.new()
     rules = %{rules | state: :players_set}
     {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
     assert rules.player1 == :islands_set 
     assert rules.player2 == :islands_not_set
     assert rules.state == :players_set

     :error = Rules.check(rules, {:position_islands, :player1})

     {:ok, rules} = Rules.check(rules, {:set_islands, :player2})

     assert rules.state == :player1_turn

     :error = Rules.check(rules, {:set_islands, :player2})

     :error = Rules.check(rules, :add_player)

     :error = Rules.check(rules, {:position_islands, :player1})

     :error = Rules.check(rules, {:position_islands, :player2})

     :error = Rules.check(rules, {:set_islands, :player1})
  end

  test "Player2 can't guess in player 1's turn" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}

    assert rules.state == :player1_turn

    :error = Rules.check(rules, {:guess_coordinate, :player2})
  end

  test "Player 1 guessing will transition to player 2's turn" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}
    {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})

    assert rules.state == :player2_turn
     
  end

  test "Player 1 can handle a no win condition" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}
    {:ok, rules} = Rules.check(rules, {:win_check, :no_win})

    assert rules.state == :player1_turn 
  end
  
  test "Player 1 can handle a win condition" do
    rules = Rules.new()
    rules = %{rules | state: :player1_turn}
    {:ok, rules} = Rules.check(rules, {:win_check, :win})

    assert rules.state == :game_over 
  end



end