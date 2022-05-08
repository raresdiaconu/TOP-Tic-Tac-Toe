$board = {
  "O": ["◢ ", " 1 ", " 2 ", " 3 "],
  "A": ["A ", "   ", "   ", "   "],
  "B": ["B ", "   ", "   ", "   "],
  "C": ["C ", "   ", "   ", "   "]
}

PLAYER_SYMBOLS = [" X ", " O "]

class Game
  def self.announce_winner(symbol)
    if symbol == PLAYER_SYMBOLS[0]
      puts 'Player 1 wins!'
    elsif symbol == PLAYER_SYMBOLS[1]
      puts 'Player 2 wins!'
    end
  end
end

class CheckWinner
  def self.column_win(hash, symbol)
    3.times do |idx|
      array = []
      hash.drop(1).each do |row, col|
        array << col[idx + 1]
      end
      all_symbols?(array, symbol)
    end
  end

  def self.row_win(hash, symbol)
    hash.drop(1).each do |row, col|
      if col.slice(1..).all? { |sym| sym == symbol}
        Game.announce_winner(symbol)
      end
    end
  end

  def self.first_diagonal_win(hash, symbol)
    i = 1
    array = []
    hash.drop(1).select do |row, col|
      array << col[i]
      i += 1
    end
    all_symbols?(array, symbol)
  end

  def self.second_diagonal_win(hash, symbol)
    i = 3
    array = []
    hash.drop(1).select do |row, col|
      array << col[i]
      i -= 1
    end
    all_symbols?(array, symbol)
  end

  def self.all_symbols?(array, symbol)
    if array.all? { |sym| sym == symbol}
      Game.announce_winner(symbol)
    end
  end
end



PLAYER_SYMBOLS.each do |symbol|
  CheckWinner.row_win($board, symbol)
  CheckWinner.column_win($board, symbol)
  CheckWinner.first_diagonal_win($board, symbol)
  CheckWinner.second_diagonal_win($board, symbol)
end





def create_board
  puts
  $board.map do |key, value|
    puts value.join
  end
  puts
end


class Player
  attr_reader :name
  def initialize(name, player_symbol)
    @name = name
    @player_symbol = player_symbol
    @moves = []
  end

  def player_pick(move)
    @moves << move
    current_move = move.split("")
    row = current_move[0].upcase.to_sym
    column = current_move[1].to_i
    if $board[row][column].strip.empty?
      $board[row][column] = @player_symbol
    else
      puts "That square is already taken. Please input different coordinates:"
      player_pick(gets.chomp.to_s)
    end
  end
end

puts "Player one (X), please input your name:"
# player_one = Player.new(gets.chomp.to_s)
player_one = Player.new("Dorel", PLAYER_SYMBOLS[0])
puts "Player two (O), what should I call you?"
# player_two = Player.new(gets.chomp.to_s)
player_two = Player.new("Borel", PLAYER_SYMBOLS[1])

puts "Alright, #{player_one.name} and #{player_two.name}, are we ready?"

create_board
puts 'You place your move by writing the coordinates. Eg: A1 or C3'
puts "Player one, make your move:"
player_one.player_pick(gets.chomp.to_s)
create_board
puts "Player two, your turn:"
player_two.player_pick(gets.chomp.to_s)
create_board