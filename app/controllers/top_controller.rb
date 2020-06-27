class TopController < ApplicationController
  def index
  end

  def clear
    Redis.new.flushdb
    game = Game.new(5)
    ActionCable.server.broadcast 'game_channel', game: game.to_h
  end

  def now
    game = Game.find(5)
    render json: { game: game.to_h }, status: 200
  end

  def put_stone
    game = Game.find(5)
    game.put(params[:point])
    ActionCable.server.broadcast 'game_channel', game: game.to_h
    render json: { result: 'ok' }, status: 200
  end
end
