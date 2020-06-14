class TopController < ApplicationController
  def index
  end

  def put_stone
    stones = params[:stones].values.push({ point: params[:point], color: params[:turn] })
    render json: { turn: change_turn(params[:turn]), stones: stones }, status: 200
  end

  private

  def change_turn(turn)
    if turn == 'brack'
      'white'
    else
      'brack'
    end
  end
end
