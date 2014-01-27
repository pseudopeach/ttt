require './ttt_ai.rb'
require './ttt_game.rb'

def game_loop
  begin
    puts ""
    puts "Would you like to go first? (y/n)"
    ans = gets.chomp!.downcase
    if ans == "y"
      play_game(true)
    elsif ans == "n"
      play_game(false)
    else
      puts "Please answer with either 'y' or 'n'."
    end
  end while(!$quit)
end

def play_game(human_first)
  
  if human_first
    cplays = :o
    hplays = :x
  else
    cplays = :x
    hplays = :o
  end
  
  #hook up players, human or otherwise
  players = {}
  players[cplays] = TttAI.new(cplays)
  players[hplays] = HumanPlayer.new(hplays)
  game = GameState.new
  game.players = players
  
  #the actual game
  winner = game.play
  
  #display outcome
  HumanPlayer.print_board(game)
  if winner == cplays
    puts "HAHAHA! Your feeble human brain is no match for my recursive power!!"
  elsif winner == :cat
    puts "It's a Tie... That seems to happen a lot in this game :-/"
  else
    #problem 102944
    puts "ZOMG! You won! How did that happen" #this message should never actually get printed
  end
  
  puts "Would you like to play again?"
  $quit = gets.chomp!.downcase != "y"
end

class HumanPlayer
  
  def initialize(mark)
    @mark = mark
  end
  
  def self.print_board(board)
    marks = board.unrolled
    hr = "----------"
    puts ""
    (0...3).each do |i|
      str = ""
      (0...3).each do |j|
        m = board.read(i,j)
        if m == :empty
          str += "(#{3*i+j+1})"
        else
          str += " #{m.to_s.upcase} "
        end
        str += "|" if j != 2
      end
      puts str
      puts hr if i != 2
    end
    puts ""
  end
  
  def move(state)
    HumanPlayer.print_board(state)
    begin
      puts "Your turn. Choose a space. (you are #{state.next_turn_taker.to_s.upcase})"
      space_num = gets.chomp!.to_i
      b = GameState.new(state)
      b.mark_index(space_num-1, @mark)
      legal = b && state.legal_moves.member?(b)
      puts "Please enter the number of an empty space." unless legal
    end while(!legal)
     
    return b
  end
end #class

puts "\nLet's play tic-tac-toe!\n"

$quit = false
game_loop
puts "Okay bye!"