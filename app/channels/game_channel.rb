class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'game_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def put_stone(data)
    game = Game.find(data['game_table_id'])
    return unless game.put(data['point'])

    ActionCable.server.broadcast 'game_channel', game: game.to_h
  end
end