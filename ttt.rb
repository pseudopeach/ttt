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
  
  players = {}
  players[cplays] = TttAI.new(cplays)
  players[hplays] = HumanPlayer.new(hplays)
  game = GameState.new
  game.players = players
  
  game.play
  
  puts "Would you like to play again?"
  $quit = gets.chomp!.downcase != "y"
end

class HumanPlayer
  
  def initialize(mark)
    
  end
  def move
    puts "human move"
  end
end

puts "Let's play tic-tac-toe!"
puts ""
$quit = false
game_loop
puts "Okay bye!"