require 'Set'

# test 37476
class GameState
  attr_accessor :board_bits, :players
  
  @@MARKS = {empty: 0, o:1, x:2}
  
  @@All_Runs = [
    #rows
    [0,1,2],
    [3,4,5],
    [6,7,8],
    
    #cols
    [0,3,6],
    [1,4,7],
    [2,5,8],
    
    #diagonals
    [0,4,8],
    [2,4,6]
  ]
  
  def initialize(bits=0)
    if bits && bits.is_a?(GameState)
      @board_bits = bits.hash
    else
      @board_bits = bits
    end 
  end
  
  def play
    raise "Player list invalid." unless @players.key?(:x) && @players.key?(:o)
    raise "Players must respond to move method" unless @players.values.inject(true){|memo, v| memo && v.respond_to?(:move)}
    
    #X starts
    current_player = :x
    
    #alternate turns until someone wins
    while(!winner) do
      move = players[current_player].move(self)
      raise "Illegal move!" unless legal_moves.member?(move)
      @board_bits = move.board_bits
      current_player = current_player == :x ? :o : :x
    end
    
    return winner
  end
  
  #checks the current board state for a winner
  #returns :x, :o, :cat, or nil if the game isn't over
  def winner
    big_p = 1
    
    marks = self.unrolled
    @@All_Runs.each do |run|
      #p = product of all the slots
      p = run.map {|i| marks[i]}.inject(:*)
      return :x if p == 8
      return :o if p == 1
      big_p *= p
    end
    
    return (big_p == 0) ? nil : :cat
  end
  
  def next_turn_taker(board=nil)
    board ||= self.unrolled
    (unrolled.inject(:+) % 3 == 0) ? :x : :o
  end
  
  #returns a set of all board configurations
  def legal_moves
    out = Set.new
    board = self.unrolled
    mark = next_turn_taker(board)
    
    board.each_with_index do |space, i|
      if space == @@MARKS[:empty]
        new_state = GameState.new(self.board_bits)
        new_state.mark_index i, mark
        out << new_state
      end
    end
    
    return out
  end
  
  def calc_idx(row, col)
    row*3 + col
  end
  
  def mark_box(row, col, mark)
    mark_index(calc_idx(row, col), mark)
  end
  
  def mark_index(idx, mark)
    raise "invalid mark" unless @@MARKS.key?(mark)
    mask = ~(3 << idx*2)
   
    @board_bits = (@board_bits & mask) | (@@MARKS[mark] << 2*idx)
  end
  
  def read(row, col)
    idx = calc_idx(row, col)
    nib = (@board_bits >> idx*2) & 3  
    GameState.translate_nibble nib, true
  end
  
  def unrolled
    n = @board_bits
    out = []
    (0...9).each do |i|
      out << (n & 3)
      n >>= 2
    end
    return out
  end
  
  def self.translate_nibble(nib, sym_only=false)
    sym = @@MARKS.find{|k,v| v == nib}.first
    return " " if !sym_only && sym == :empty
    return sym
  end
  
  def print
    marks = self.unrolled
    hr = "----------"
    puts ""
    puts " " +  marks[0...3].map{|q| GameState.translate_nibble q}.join(" | ")
    puts hr
    puts " " + marks[3...6].map{|q| GameState.translate_nibble q}.join(" | ")
    puts hr
    puts " " + marks[6...9].map{|q| GameState.translate_nibble q}.join(" | ")
    puts ""
  end
  
  def hash
    @board_bits
  end
  
  def eql?(other)
    other.board_bits == @board_bits
  end
end