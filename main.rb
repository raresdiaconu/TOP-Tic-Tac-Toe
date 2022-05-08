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
    initialize_players unless @keep_names
    play_round while @winner == false
  end

  def self.initialize_players
    puts 'Player one (X), please input your name:'
    @player_one = Player.new(gets.chomp.to_s, PLAYER_SYMBOLS[0])
    puts 'Player two (O), what should I call you?'
    @player_two = Player.new(gets.chomp.to_s, PLAYER_SYMBOLS[1])
    describe_game
  end

  def self.describe_game
    puts
    puts "Alright, #{@player_one.name} and #{@player_two.name}, are we ready?"
    puts 'Place your symbol by writing the coordinates [eg: A1 or C3].'
  end

  def self.play_round
    player_one_round
    player_two_round
  end

  def self.player_one_round
    create_board
    puts "#{@player_one.name}, make your move:"
    @player_one.check_move_validity(gets.chomp.to_s.split(''))
    return if check_for_winner_row_and_col
  end

  def self.player_two_round
    create_board
    puts "#{@player_two.name}, it's your turn:"
    @player_two.check_move_validity(gets.chomp.to_s.split(''))
    return if check_for_winner_row_and_col
  end

  def self.create_board
    puts
    @@board.map { |_key, row| puts row.join }
    puts
  end

  def self.check_for_winner_row_and_col
    PLAYER_SYMBOLS.each do |symbol|
      CheckWinner.row_win(@@board, symbol) unless @winner
      CheckWinner.column_win(@@board, symbol) unless @winner
    end
    return true if @winner

    check_for_winner_diagonals
  end

  def self.check_for_winner_diagonals
    PLAYER_SYMBOLS.each do |symbol|
      CheckWinner.first_diagonal_win(@@board, symbol) unless @winner
      CheckWinner.second_diagonal_win(@@board, symbol) unless @winner
    end
    return true if @winner

    check_for_tie
  end

  def self.check_for_tie
    PLAYER_SYMBOLS.each do
      CheckWinner.tie?(@@board, @winner) unless @winner
    end
    return true if @winner
  end

  def self.announce_winner(symbol)
    @winner = true
    create_board
    if symbol == PLAYER_SYMBOLS[0]
      puts "#{@player_one.name} wins!"
    elsif symbol == PLAYER_SYMBOLS[1]
      puts "#{@player_two.name} wins!"
    end
    play_again
  end

  def self.annouce_tie
    create_board
    puts 'It\'s a tie!'
    play_again
  end

  def self.play_again
    puts
    puts 'Play again? [enter a number to make a selection]'
    puts '[1] Same players'
    puts '[2] New players'
    puts '[3] Exit'
    puts '-' * 20
    puts "[4] Swap symbols? #{@player_two.name} will play X and move first. "
    play_again_logic(gets.chomp.to_s)
  end

  def self.play_again_logic(input)
    case input
    when '1'
      reset_game
      @keep_names = true
      start_game
    when '2'
      reset_game
      start_game
    when '3'
      exit
    when '4'
      temp = @player_one.name
      @player_one.name = @player_two.name
      @player_two.name = temp
      reset_game
      @keep_names = true
      start_game
    else
      puts 'Please enter an option [eg: 1] to continue or exit.'
      play_again
    end
  end

  def self.reset_game
    @@board = {
      'O': ['◢ ', ' 1 ', ' 2 ', ' 3 '],
      'A': ['A ', '   ', '   ', '   '],
      'B': ['B ', '   ', '   ', '   '],
      'C': ['C ', '   ', '   ', '   ']
    }
    @winner = false
    @keep_names = false
  end
end

# Creates the players, adds the player's pick to the board.
class Player < Game
  attr_accessor :name, :moves

  def initialize(name, player_symbol)
    @name = name
    @player_symbol = player_symbol
  end

  def check_move_validity(move)
    return make_another_move if move.length != 2
    return make_another_move unless !!move[0].match(/[abc]/i) && !!move[1].match(/\d/)

    convert_move(move)
  end

  def convert_move(move)
    player_move(move[0].upcase.to_sym, move[1].to_i)
  end

  def player_move(row, column)
    if @@board[row][column].strip.empty?
      @@board[row][column] = @player_symbol
    else
      puts 'That square is already taken. Please input different coordinates:'
      check_move_validity(gets.chomp.to_s.split(''))
    end
  end

  def make_another_move
    puts 'Invalid input. Place your symbol by writing the coordinates [eg: A1 or C3].'
    check_move_validity(gets.chomp.to_s.split(''))
  end
end

# Checks for a winner (all 3 symbols in a column, row or diagonally)
class CheckWinner < Game
  def self.column_win(board, symbol)
    3.times do |idx|
      matches = []
      board.drop(1).each do |_key, row|
        matches << row[idx + 1]
      end
      all_symbols?(matches, symbol)
    end
  end

  def self.row_win(board, symbol)
    board.drop(1).each do |_key, row|
      Game.announce_winner(symbol) if row.slice(1..).all? { |sym| sym == symbol }
    end
  end

  def self.first_diagonal_win(board, symbol)
    i = 1
    matches = []
    board.drop(1).select do |_key, row|
      matches << row[i]
      i += 1
    end
    all_symbols?(matches, symbol)
  end

  def self.second_diagonal_win(board, symbol)
    i = 3
    matches = []
    board.drop(1).select do |_key, row|
      matches << row[i]
      i -= 1
    end
    all_symbols?(matches, symbol)
  end

  def self.all_symbols?(matches, symbol)
    return unless matches.all? { |sym| sym == symbol }

    Game.announce_winner(symbol)
  end

  def self.tie?(board, winner)
    matches = []
    board.drop(1).each { |_key, row| matches << row.slice(1..) }
    matches.flatten!
    matches.collect!(&:strip)
    matches.reject!(&:empty?)
    Game.annouce_tie if matches.length == 9 && !winner
  end
end

Game.start_game
