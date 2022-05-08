require 'pry-byebug'

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
    puts
    puts "Alright, #{@player_one.name} and #{@player_two.name}, are we ready?"
    puts 'Place your symbol by writing the coordinates [eg: A1 or C3].'
  end

  def self.play_round
    create_board
    puts "#{@player_one.name}, make your move:"
    @player_one.player_pick(gets.chomp.to_s)
    return if check_for_winner
    create_board
    puts "#{@player_two.name}, it's your turn:"
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
      CheckWinner.is_tie?(@@board, @winner) unless @winner
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
    puts 'Play again? [enter a number make a selection]'
    puts '[1] Same players'
    puts '[2] New players'
    puts '[3] Exit'
    puts '-' * 20
    puts "[4] Swap symbols? #{@player_two.name} will play X and move first. "
    puts "[5] See all of #{@player_one.name}'s moves."
    puts "[6] See all of #{@player_two.name}'s moves."
    answer = gets.chomp.to_s
    if answer == '1'
      reset_game
      @keep_names = true
      start_game
    elsif answer == '2'
      reset_game
      start_game
    elsif answer == '3'
      exit
    elsif answer == '4'
      temp = @player_one.name
      @player_one.name = @player_two.name
      @player_two.name = temp

      reset_game
      @keep_names = true
      start_game
    elsif answer == '5'
      puts
      puts "#{@player_one.name} has played:"
      print @player_one.moves
      puts
      play_again
    elsif answer == '6'
      puts
      puts "#{@player_two.name} has played:"
      print @player_two.moves
      puts
      play_again
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
    @player_one.moves = []
    @player_two.moves = []
  end
end

# Creates the players, adds the player's pick to the board.
class Player < Game
  attr_accessor :name, :moves

  def initialize(name, player_symbol)
    @name = name
    @player_symbol = player_symbol
    @moves = []
  end

  def player_pick(move="00")
    current_move = move.split('')
    return make_another_pick(move) if current_move.length != 2
    return make_another_pick(move) unless !!current_move[0].match(/[abc]/i) && !!current_move[1].match(/\d/)
    @moves << move
    row = current_move[0].upcase.to_sym
    column = current_move[1].to_i
    if @@board[row][column].strip.empty?
      @@board[row][column] = @player_symbol
    else
      puts 'That square is already taken. Please input different coordinates:'
      player_pick(gets.chomp.to_s)
    end
  end

  def make_another_pick(move)
      puts 'Invalid input. Place your symbol by writing the coordinates [eg: A1 or C3].'
      player_pick(gets.chomp.to_s)
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

  def self.is_tie?(hash, winner)
    array = []
    hash.drop(1).each { |_key, row| array << row.slice(1..)} 
    array.flatten!
    array.collect!(&:strip)
    array.reject!(&:empty?)
    Game.annouce_tie if array.length == 9 && !winner
  end
end

Game.start_game