class Game
  attr_accessor :id, :turn, :move, :black_stones, :white_stones, :black_time, :white_time
  TURN = { BLACK: 0, WHITE: 1 }.freeze

  def initialize(game_id = nil)
    if game_id.present?
      @id = game_id
      @move = 1
      @turn = TURN[:BLACK]
      @black_time = 20 * 60
      @white_time = 20 * 60
      @black_stones = 0x0000000810000000
      @white_stones = 0x0000001008000000
      save
    end
  end

  def self.find(game_id)
    Redis.current.with do |redis|
      return Game.new(game_id) if redis.get("game:#{game_id}:move").nil?
  
      game = Game.new
      game.id = game_id
      game.move = redis.get("game:#{game_id}:move").to_i
      game.turn = redis.get("game:#{game_id}:turn").to_i
      game.black_time = redis.get("game:#{game_id}:black_time").to_i
      game.white_time = redis.get("game:#{game_id}:white_time").to_i
      game.black_stones = redis.get("game:#{game_id}:black_stones").to_i
      game.white_stones = redis.get("game:#{game_id}:white_stones").to_i
      game
    end
  end

  def put(point)
    board = to_board
    if board.can_put?(point)
      board.reverse(point)
      @black_stones = black_turn? ? board.player_stones : board.opponent_stones
      @white_stones = black_turn? ? board.opponent_stones : board.player_stones
      @turn = change_turn unless board.opponent_board.pass?
      @move += 1
      save
    end
  end

  private

  def save
    Redis.current.with do |redis|
      redis.set("game:#{@id}:id", @id)
      redis.set("game:#{@id}:move", @move)
      redis.set("game:#{@id}:turn", @turn)
      redis.set("game:#{@id}:black_time", @black_time)
      redis.set("game:#{@id}:white_time", @white_time)
      redis.set("game:#{@id}:black_stones", @black_stones)
      redis.set("game:#{@id}:white_stones", @white_stones)
    end
  end

  def to_board
    if black_turn?
      Board.new(player_stones: @black_stones, opponent_stones: @white_stones)
    else
      Board.new(player_stones: @white_stones, opponent_stones: @black_stones)
    end
  end

  def black_turn?
    @turn == TURN[:BLACK]
  end

  def change_turn
    if black_turn?
      TURN[:WHITE]
    else
      TURN[:BLACK]
    end
  end
end
