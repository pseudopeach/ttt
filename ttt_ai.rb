require './ttt_game.rb'

class TttAI

  def initialize(playing_mark)
    @opponent = playing_mark == :o ? :x : :o
    @playing_mark = playing_mark
    @iteration_count = 0
    @TAB_CACHE = {}
  end
  
  def move(state)
    @iteration_count = 0
    #make an array of all possible moves
    choices = []
    state.legal_moves.each do |move| 
      hash = tabulate_outcomes(move)
      hash[:move] = move
      choices << hash
    end
    puts "Finished tabulation in #{@iteration_count} calls."
    
    #pick the one that looses the least, breaking ties by drawing the least
    best = choices.sort_by { |c| [-c[:worst_case], c[@playing_mark]] }.first
    return best[:move]
  end
  
  def tabulate_outcomes(state)
    
    #return early if we have a pre-tabulated solution
    if out = @TAB_CACHE[state.board_bits]
      return out
    end
    
    @iteration_count += 1
    out = {x: 0, o: 0, cat:0, worst_case: 0}
    
    if w = state.winner
      out[w] = 1
      out[:worst_case] = -1 if w == @opponent
      out[:worst_case] = 1 if w == @playing_mark
      #puts "winner #{w} #{out[:worst_case]}"
      return out
    end
    
    #loop through each possible move
    state.legal_moves.each do |q|
      outcomes = tabulate_outcomes q
      
      #raw counts
      [:x, :o, :cat].each {|k| out[k] += outcomes[k]}
      
      #if it's the other player's turn assume the pick the worst, and vice versa
      if state.next_turn_taker == @opponent
        out[:worst_case] = outcomes[:worst_case] if outcomes[:worst_case] < out[:worst_case]
      else
        out[:worst_case] = outcomes[:worst_case] if outcomes[:worst_case] > out[:worst_case]
        puts "on computer turn: move worst:#{outcomes[:worst_case]} output worst:#{out[:worst_case]}"
      end    
    end
    
    cache_solution(state, out)
    
    return out
  end
  
  #cache all symmetric layouts of [state]
  def cache_solution(state, outcomes)
    @TAB_CACHE[state.board_bits] = outcomes
    alt = state
    3.times do
      alt = rotate_state alt
      @TAB_CACHE[alt.board_bits] = outcomes
    end
    
    alt = flip_state state
    @TAB_CACHE[alt.board_bits] = outcomes
    3.times do
      alt = rotate_state alt
      @TAB_CACHE[alt.board_bits] = outcomes
    end
  end
  
  def flip_state(state)
    out = GameState.new 
    (0...3).each do |i|
      (0...3).each do |j|
        out.mark_box( i,j, state.read(i,2-j))
      end
    end
    return out
  end
  
  def rotate_state(state)
    out = GameState.new
    (0...3).each do |i|
      (0...3).each do |j|
        out.mark_box( i,j, state.read(2-j,i))
      end
    end
    return out
  end
end

