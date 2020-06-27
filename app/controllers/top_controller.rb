class TopController < ApplicationController
  def index
    Redis.new.flushdb
    Game.new(5)
  end

  def put_stone
    game = Game.find(5)
    game.put(params[:point])
    render json: { turn: game.turn, black_stones: "%016x"%game.black_stones, white_stones: "%016x"%game.white_stones }, status: 200
  end
end
