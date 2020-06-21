class TopController < ApplicationController
  def index
  end

  def put_stone
    board = Board.new
    blacks = params[:stones].values.filter { |stone| stone[:color] == 'black' }
                 .map { |stone| board.coordinate_to_bit(stone[:point]) }.inject(:|)
    whites = params[:stones].values.filter { |stone| stone[:color] == 'white' }
                 .map { |stone| board.coordinate_to_bit(stone[:point]) }.inject(:|)

    if params[:turn] == 'black'
      board.player_board = blacks
      board.opponent_board = whites
    else
      board.player_board = whites
      board.opponent_board = blacks
    end

    turn = params[:turn]
    if board.can_put?(board.coordinate_to_bit(params[:point]))
      board.reverse(board.coordinate_to_bit(params[:point]))
      turn = change_turn(params[:turn]) unless board.to_opponent.pass?
    end

    stones = board.player_board.to_s(2).rjust(64, '0').split(//).map.with_index do |bit, i|
      if bit == '1'
        { point: ('A'.ord + i.modulo(8)).chr + (i.div(8) + 1).to_s, color: params[:turn] }
      end
    end.compact

    stones.push(board.opponent_board.to_s(2).rjust(64, '0').split(//).map.with_index do |bit, i|
      if bit == '1'
        { point: ('A'.ord + i.modulo(8)).chr + (i.div(8) + 1).to_s, color: change_turn(params[:turn]) }
      end
    end.compact)
    stones.flatten!

    render json: { turn: turn, stones: stones.map.with_index { |stone, i| [i.to_s, stone] }.to_h }, status: 200
  end

  private

  def change_turn(turn)
    if turn == 'black'
      'white'
    else
      'black'
    end
  end
end
