require './ttt_ai.rb'
require './ttt_game.rb'


#problem 102944
b = GameState.new 102944

raise "broken turn taker" unless b.next_turn_taker == :o
b2 = GameState.new b
b2.mark_box 0,0, :o
raise "legal move deemed illegal" unless b.legal_moves.member?(b2)
b2.mark_box 0,0, :x
raise "illegal move deemed legal" if b.legal_moves.member?(b2)

#ai test
ai = TttAI.new(:o)
#must make move that prevents immediate loss
raise "AI is stupid" unless ai.move(b).hash == 102948

puts "*** all tests passed ***"
