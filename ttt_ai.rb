require './ttt_game.rb'

class TttAI
  attr_accessor :iter
  def initialize(playing_mark)
    @opponent = playing_mark == :o ? :x : :o
    @playing_mark = playing_mark
    @TAB_CACHE = {}
  end
  
  def pick_move(state)
    #make an array of all possible moves
    @iteration_count = 0
    choices = state.legal_moves.map {|move| tabulate_outcomes(move)[:move] = move }
    puts "Finished tabulation in #{@iteration_count} calls."
    
    #pick the one that looses the least, breaking ties by drawing the least
    return choices.sort_by { |c| [c[@opponent], c[:cat]] }.first
  end
  
  def tabulate_outcomes(state)
    
    #return early if we have a pre-tabulated solution
    if out = @TAB_CACHE[state.board_bits]
      return out
    end
    
    @iteration_count += 1
    out = {x: 0, o: 0, cat: 0}
    
    if w = state.winner
      out[w] += 1
      return out
    end
    
    state.legal_moves.each do |q|
      outcomes = tabulate_outcomes q
      outcomes.each { |k,v| out[k] += v }
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

