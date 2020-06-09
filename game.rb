class PlayerSymbol
  def to_s
    "X"
  end

  def opposite
    AI_SYMBOL
  end
end

class AISymbol
  def to_s
    "O"
  end

  def opposite
    PLAYER_SYMBOL
  end
end

AI_SYMBOL = AISymbol.new
PLAYER_SYMBOL = PlayerSymbol.new
EMPTY_CELL = " " 

class Board
  def initialize(cells={})
    @cells = cells
  end

  def clear
    1.upto(9).each { |cell_number| self[cell_number] = EMPTY_CELL }
  end

  def clone
    Board.new(@cells.clone)
  end

  def to_s
    "| #{self[1]} | #{self[2]} | #{self[3]} |\n" + 
      "-------------\n"+
      "| #{self[4]} | #{self[5]} | #{self[6]} |\n" + 
      "-------------\n"+
      "| #{self[7]} | #{self[8]} | #{self[9]} |\n" 
  end

  def is_game_finished?
    is_winner?(PLAYER_SYMBOL) || is_winner?(AI_SYMBOL) || count_empty_cells == 0 
  end

  def is_winner? symbol
    has_three_of_same_in_row?(symbol,1) ||
      has_three_of_same_in_row?(symbol,2) ||
      has_three_of_same_in_row?(symbol,3) ||
      has_three_of_same_in_column?(symbol,1) ||
      has_three_of_same_in_column?(symbol,2) ||
      has_three_of_same_in_column?(symbol,3) ||
      has_three_of_same_in_first_diagonal?(symbol) ||
      has_three_of_same_in_second_diagonal?(symbol)
  end

  def count_empty_cells
    count(EMPTY_CELL)
  end

  def count(symbol)
    count = 0
    1.upto(9).each do |cell_number|
      if self[cell_number] == symbol
        count += 1
      end
    end
    count
  end

  def has_three_of_same_in_row?(symbol,row_number) 
    max_cell_number = row_number * 3
    string = ""
    (max_cell_number-2).upto(max_cell_number) do |cell_number|
      string += self[cell_number].to_s
    end
    string == symbol.to_s * 3
  end

  def has_three_of_same_in_column?(symbol,column_number) 
    string = ""
    (column_number..(column_number+6)).step(3) do |cell_number|
      string += self[cell_number].to_s
    end
    string == symbol.to_s * 3
  end

  def has_three_of_same_in_first_diagonal?(symbol)
    string = ""
    (1..9).step(4) do |cell_number|
      string += self[cell_number].to_s
    end
    string == symbol.to_s * 3
  end

  def has_three_of_same_in_second_diagonal?(symbol)
    string = ""
    (3..7).step(2) do |cell_number|
      string += self[cell_number].to_s
    end
    string == symbol.to_s * 3
  end

  def [](cell_number)
    @cells[cell_number.to_s.to_sym]
  end

  def []=(cell_number,symbol)
    @cells[cell_number.to_s.to_sym] = symbol
  end

  def play_at(symbol, cell_number)
    board = self.clone
    board[cell_number] = symbol
    board
  end
end

class AI
  def initialize(symbol)
    @symbol = symbol
  end

  def play(board)
    if board.is_game_finished?
      return board
    end

    if board.count_empty_cells >= 8
      cell_number = play_at_first_empty_cell(board)
    else
      cell_number = find_best_move(board)
    end

    board.play_at(@symbol, cell_number)
  end

  def play_at_first_empty_cell(board)
    if board[5] == EMPTY_CELL
      5
    else
      cell_number = 1
      while board[cell_number] != EMPTY_CELL
        cell_number += 1 
      end
      cell_number
    end
  end

  def find_best_move(board)
    moves = []
    1.upto(9).each do |cell_number| 
      if board[cell_number] == EMPTY_CELL 
        move = Move.new(self, board, cell_number, @symbol)
        move.compute_score
        moves << move
      end
    end
    moves = moves.sort
    moves[0].cell_number
  end
end

class Move
  def initialize(ai, board, cell_number, symbol)
    @ai = ai
    @player_simulation = AI.new(symbol.opposite)
    @board = board
    @symbol = symbol
    @cell_number = cell_number
    @score = 0
  end

  def <=>(other)
    other.score <=> self.score
  end

  def cell_number
    @cell_number
  end

  def score
    @score
  end

  def compute_score
    empty_before_playing = @board.count_empty_cells 
    @board = @board.play_at(@symbol, @cell_number)
    while not @board.is_game_finished?
      @board = @player_simulation.play(@board)
      @board = @ai.play(@board)
    end
    if @board.is_winner?(@symbol)
      @score = 2 
    elsif @board.is_winner?(@symbol.opposite)
      @score = -1
    else
      @score = 1
    end
  end
end

class Game
  def run
    ai = AI.new(AI_SYMBOL)
    board = Board.new
    board.clear
    puts "Do you want to play first? Y/N"
    if gets.upcase.start_with?("Y")
      puts "Player plays first"
    else
      puts "AI plays first"
      board = ai.play(board)
    end
    while not board.is_game_finished?
      puts board
      puts "Write the cell number (1-9) you want to place your X at:"
      cell_number = 0
      while cell_number < 1 || cell_number > 9
        begin
          cell_number = gets.to_i
        rescue
          cell_number = 0
        end
        if board[cell_number] != EMPTY_CELL 
          cell_number = 0
          puts "Invalid cell number"
        end
      end
      board = board.play_at(PLAYER_SYMBOL, cell_number)
      board = ai.play(board)
    end
    puts board
    if board.is_winner? PLAYER_SYMBOL
      puts "Player wins!"
    elsif board.is_winner? AI_SYMBOL
      puts "AI wins!"
    else
      puts "Tie!"
    end
  end
end

Game.new.run
