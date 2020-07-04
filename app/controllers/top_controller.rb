class TopController < ApplicationController
  def index
    @game_id = params[:id]
  end

  def clear
    Redis.new.flushdb
    game = Game.new_game(params[:id], 2, 3)
    ActionCable.server.broadcast 'game_channel', game: game.to_h
  end

  def latest
    game = Game.find(params[:id])
    render json: { game: game.to_h }, status: 200
  end
end
