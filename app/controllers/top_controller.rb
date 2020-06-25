class TopController < ApplicationController
  def index
    Redis.new.flushdb
    Game.new(5)
  end

  def put_stone
    game = Game.find(5)
    game.put(params[:point])
    # game_log(game)
    render json: { turn: game.turn, black_stones: "%016x"%game.black_stones, white_stones: "%016x"%game.white_stones }, status: 200
  end

  def game_log(game)
    (0..63).each do |i|
      print game.black_stones & (0x8000000000000000 >> i) > 0 ? 1 : 0
      puts '' if i % 8 == 7
    end
  end
end
