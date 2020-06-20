class Board
  # 現在の手番, 現在何手目か, player側ビットボード, opponent側ビットボード
  attr_accessor :now_turn, :now_index, :player_board, :opponent_board

  # MARK: Constant
  BLACK_TURN = 100
  WHITE_TURN = -100

  # MARK: Initialization
  def init
    @now_turn = BLACK_TURN
    @now_index = 1

    # 一般的な初期配置を指定
    @player_board = 0x0000000810000000
    @opponent_board = 0x0000001008000000
  end

  # brief 座標をbitに変換する
  # param x 横座標(A~H)
  # param y 縦座標(1~8)
  # return 着手箇所のみにフラグが立っている64ビット
  def coordinate_to_bit(x, y)
    mask = 0x8000000000000000
    # X方向へのシフト
    mask = mask >> (x.ord - 'A'.ord)
    # Y方向へのシフト
    mask >> ( (y.to_i - 1) * 8)
  end
end