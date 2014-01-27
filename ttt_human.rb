require './ttt_game.rb'
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
      puts "Your turn. Choose a space."
      space_num = gets.chomp!.to_i
      b = GameState.new(state)
      b.mark_index(space_num-1, @mark)
      legal = b && state.legal_moves.member?(b)
      puts "Please enter the number of an empty space." unless legal
    end while(!legal)
     
    return b
  end
end #class