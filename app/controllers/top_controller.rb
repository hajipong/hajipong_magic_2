class TopController < ApplicationController
  def index
    Redis.new.flushdb
    Game.new(5)
  end

  def put_stone
    game = Game.find(5)
    game.put(params[:point])

    stones = game.black_stones.to_s(2).rjust(64, '0').split(//).map.with_index do |bit, i|
      if bit == '1'
        { point: ('A'.ord + i.modulo(8)).chr + (i.div(8) + 1).to_s, color: 'black' }
      end
    end.compact

    stones.push(game.white_stones.to_s(2).rjust(64, '0').split(//).map.with_index do |bit, i|
      if bit == '1'
        { point: ('A'.ord + i.modulo(8)).chr + (i.div(8) + 1).to_s, color: 'white' }
      end
    end.compact)
    stones.flatten!

    render json: { turn: game.turn, stones: stones.map.with_index { |stone, i| [i.to_s, stone] }.to_h }, status: 200
  end
end
