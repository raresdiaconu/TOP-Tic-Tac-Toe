# require 'pry-byebug'

# Puts all of the game together
class Game
  @@board = {
    'O': ['◢ ', ' 1 ', ' 2 ', ' 3 '],
    'A': ['A ', '   ', '   ', '   '],
    'B': ['B ', '   ', '   ', '   '],
    'C': ['C ', '   ', '   ', '   ']
  }
  PLAYER_SYMBOLS = [' X ', ' O ']
  @winner = false

  def self.start_game
    initialize_players
    while @winner == false
      play_round
    end
    # return unless @winner = true

  end

  def self.initialize_players
    puts 'Player one (X), please input your name:'
    @player_one = Player.new(gets.chomp.to_s, PLAYER_SYMBOLS[0])
    puts 'Player two (O), what should I call you?'
    @player_two = Player.new(gets.chomp.to_s, PLAYER_SYMBOLS[1])

    puts "Alright, #{@player_one.name} and #{@player_two.name}, are we ready?"
    puts 'Place your move by writing the coordinates. Eg: A1 or C3'
  end

  def self.play_round
    create_board
    puts "#{@player_one.name}, make your move:"
    @player_one.player_pick(gets.chomp.to_s)
    return if check_for_winner
    create_board
    puts "#{@player_two.name}, your turn:"
    @player_two.player_pick(gets.chomp.to_s)
    return if check_for_winner
  end

  def self.create_board
    puts
    @@board.map { |_key, row| puts row.join } 
    puts
  end

  def self.check_for_winner
    PLAYER_SYMBOLS.each do |symbol|
      CheckWinner.row_win(@@board, symbol) unless @winner
      CheckWinner.column_win(@@board, symbol) unless @winner
      CheckWinner.first_diagonal_win(@@board, symbol) unless @winner
      CheckWinner.second_diagonal_win(@@board, symbol) unless @winner
    end
    return true if @winner
  end

  def self.announce_winner(symbol)
    @winner = true
    if symbol == PLAYER_SYMBOLS[0]
      puts 'Player 1 wins!'
    elsif symbol == PLAYER_SYMBOLS[1]
      puts 'Player 2 wins!'
    end
  end
end

# Checks for a winner (all 3 symbols on a column, row, diagonally)
class CheckWinner < Game
  def self.column_win(hash, symbol)
    3.times do |idx|
      array = []
      hash.drop(1).each do |_key, row|
        array << row[idx + 1]
      end
      all_symbols?(array, symbol)
    end
  end

  def self.row_win(hash, symbol)
    # binding.pry
    hash.drop(1).each do |_key, row|
      if row.slice(1..).all? {|sym| sym == symbol}
        Game.announce_winner(symbol)
      end
    end
  end

  def self.first_diagonal_win(hash, symbol)
    i = 1
    array = []
    hash.drop(1).select do |_key, row|
      array << row[i]
      i += 1
    end
    all_symbols?(array, symbol)
  end

  def self.second_diagonal_win(hash, symbol)
    i = 3
    array = []
    hash.drop(1).select do |_key, row|
      array << row[i]
      i -= 1
    end
    all_symbols?(array, symbol)
  end

  def self.all_symbols?(array, symbol)
    return unless array.all? { |sym| sym == symbol }

    Game.announce_winner(symbol)
  end
end

# Creates the players, adds the player's pick to the board.
class Player < Game
  attr_reader :name

  def initialize(name, player_symbol)
    @name = name
    @player_symbol = player_symbol
    @moves = []
  end

  def player_pick(move)
    @moves << move
    current_move = move.split('')
    row = current_move[0].upcase.to_sym
    column = current_move[1].to_i
    if @@board[row][column].strip.empty?
      @@board[row][column] = @player_symbol
    else
      puts 'That square is already taken. Please input different coordinates:'
      player_pick(gets.chomp.to_s)
    end
  end
end

Game.start_game