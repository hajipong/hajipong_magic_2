# 対局進行状況を表すモデル
class Game
  include ActiveModel::Model

  attr_accessor :id, :turn, :move, :black_stones, :white_stones, :black_time, :white_time, :black_user_id, :white_user_id
  TURN = { BLACK: 0, WHITE: 1 }.freeze

  def self.new_game(game_id, black_user_id, white_user_id)
    game = Game.new(id: game_id, move: 1, turn: TURN[:BLACK],
                    black_time: 20 * 60, white_time: 20 * 60,
                    black_stones: 0x0000000810000000,
                    white_stones: 0x0000001008000000,
                    black_user_id: black_user_id,
                    white_user_id: white_user_id)
    game.save
    game
  end

  def self.find(game_id)
    Redis.current.with do |redis|
      data = JSON.parse(redis.get("game:#{game_id}"), symbolize_names: true)
      return Game.new if data.nil?

      Game.new(id: game_id, move: data[:move].to_i, turn: data[:turn].to_i,
               black_time: data[:black_time].to_i, white_time: data[:white_time].to_i,
               black_stones: data[:black_stones].to_i, white_stones: data[:white_stones].to_i,
               black_user_id: data[:black_user_id].to_i, white_user_id: data[:white_user_id].to_i)
    end
  end

  def put(point)
    board = to_board
    return false unless board.can_put?(point)

    board.reverse(point)
    @black_stones = black_turn? ? board.player_stones : board.opponent_stones
    @white_stones = black_turn? ? board.opponent_stones : board.player_stones
    @turn = change_turn unless board.opponent_board.pass?
    @move += 1
    save
    true
  end

  def user_turn?(user)
    return false if user.nil?

    black_turn? && user.id == @black_user_id || !black_turn? && user.id == @white_user_id
  end

  def to_h
    { turn: @turn, black_stones: format('%<stones>016x', stones: @black_stones),
      white_stones: format('%<stones>016x', stones: @white_stones) }
  end

  def save
    Redis.current.with do |redis|
      data = { id: @id, move: @move, turn: @turn,
               black_time: @black_time, white_time: @white_time,
               black_stones: @black_stones, white_stones: @white_stones,
               black_user_id: @black_user_id, white_user_id: @white_user_id }.to_json
      redis.set("game:#{@id}", data)
    end
  end

  private

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
