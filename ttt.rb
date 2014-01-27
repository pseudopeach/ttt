require './ttt_ai.rb'
require './ttt_game.rb'
require './ttt_human.rb'

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
    puts "ZOMG! You won! How did that happen" #this message should never actually get printed
  end
  
  puts "Would you like to play again?"
  $quit = gets.chomp!.downcase != "y"
end

puts "\nLet's play tic-tac-toe!\n"

$quit = false
game_loop
puts "Okay bye!"