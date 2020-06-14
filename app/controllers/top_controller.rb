class TopController < ApplicationController
  def index
  end

  def put_stone
    stones = params[:stones].values.push({ point: params[:point], color: params[:color] })
    render json: stones, status: 200
  end
end
