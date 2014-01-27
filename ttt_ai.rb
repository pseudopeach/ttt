require './ttt_game.rb'

class TttAI
  def initialize(playing_mark)
    @opponent = playing_mark == :o ? :x : :o
    @playing_mark = playing_mark
    @iteration_count = 0
    @TAB_CACHE = {}
  end
  
  #return a move (BoardState) given [state]
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
    
    #pick best worst case scenario
    best = choices.sort_by { |c| [-c[:worst], -c[@playing_mark]] }.first
    return best[:move]
  end
  
  #for a given state, tabulate all possible outcomes
  def tabulate_outcomes(state)
    #return early if we have a cached solution for the given [state]
    if out = @TAB_CACHE[state.board_bits]
      return out
    end
    
    @iteration_count += 1
    out = {x: 0, o: 0, cat:0}
    
    #if this state has a winner, it's easy
    if w = state.winner
      out[w] = 1
      case w
        when @opponent
          out[:worst] = -1
        when @playing_mark
          out[:worst] = 1
        else
          out[:worst] = 0
      end
      
      return out
    end
    
    #loop through each possible move
    state.legal_moves.each do |q|
      outcomes = tabulate_outcomes q
      
      #raw counts
      [:x, :o, :cat].each {|k| out[k] += outcomes[k]}
      
      #if it's the other player's turn assume they make the best move they can, and vice versa
      if state.next_turn_taker == @opponent
        out[:worst] = outcomes[:worst] if (!out[:worst] || (outcomes[:worst] < out[:worst]))
      else
        out[:worst] = outcomes[:worst] if (!out[:worst] || (outcomes[:worst] > out[:worst]))
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

