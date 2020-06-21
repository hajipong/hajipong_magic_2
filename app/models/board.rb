class Board
  # 現在の手番, 現在何手目か, player側ビットボード, opponent側ビットボード
  attr_accessor :now_turn, :now_index, :player_board, :opponent_board

  # MARK: Constant
  BLACK_TURN = 100
  WHITE_TURN = -100

  def initialize
    init
  end

  # MARK: Initialization
  def init
    @now_turn = BLACK_TURN
    @now_index = 1

    # 一般的な初期配置を指定
    @player_board = 0x0000000810000000
    @opponent_board = 0x0000001008000000
  end

  # 座標をbitに変換する
  # x 横座標(A~H)
  # y 縦座標(1~8)
  # return 着手箇所のみにフラグが立っている64ビット
  def coordinate_to_bit(x, y)
    mask = 0x8000000000000000
    # X方向へのシフト
    mask = mask >> (x.ord - 'A'.ord)
    # Y方向へのシフト
    mask >> ( (y.to_i - 1) * 8)
  end

  # 着手可否の判定
  # put 置いた位置のみにフラグが立っている64ビット
  # return 着手可能ならtrue
  def can_put?(put)
    # 着手可能なマスにフラグが立っている合法手ボードを生成
    legal_board = make_legal_board(self)
    # 今回の着手が、その合法手ボードに含まれれば着手可能
    put & legal_board == put
  end

  # 着手し,反転処理を行う
  # put: 着手した場所のみにフラグが立つ64ビット
  def reverse(put)
    # 着手した場合のボードを生成
    rev = 0
    (0..7).each do |k|
      rev_ = 0
      # 着手地点から書く方向にシフト
      mask = transfer(put: put, k: k)
      # シフト地点が盤内であり、相手の石が存在すれば実行
      while (mask != 0) && ((mask & opponent_board) != 0) do
        # 反転地点の仮記録
        rev_ |= mask
        # 次のマスへ
        mask = transfer(put: mask, k: k)
      end
      # 到着地点に自分の種石があれば本記録
      if (mask & player_board) != 0
        rev |= rev_
      end
    end
    # 反転する
    @player_board   ^= put | rev
    @opponent_board ^= rev
    # 現在何手目かを更新
    @now_index += 1
  end

  private

  # 手番側の合法手ボードを生成
  # board Boardインスタンス
  # return Uint64  playerから見て、置けるマスのみにフラグが立っている64ビット
  def make_legal_board(board)
    # 左右端の番人
    horizontal_watch_board = board.opponent_board & 0x7e7e7e7e7e7e7e7e
    # 上下端の番人
    vertical_watch_board = board.opponent_board & 0x00FFFFFFFFFFFF00
    # 全辺の番人
    all_side_watch_board = board.opponent_board & 0x007e7e7e7e7e7e00
    # 空きマスのみにビットが立っているボード
    blank_board = ~(board.player_board | board.opponent_board)

    # 8方向チェック
    # ・一度に返せる石は最大6つ ・高速化のためにforを展開(ほぼ意味ないけどw)
    # 左
    left_shift = ->(shift_board) { shift_board << 1 }
    legal_board = legal_board(board.player_board, horizontal_watch_board, blank_board, left_shift)

    # 右
    right_shift = ->(shift_board) { shift_board >> 1 }
    legal_board |= legal_board(board.player_board, horizontal_watch_board, blank_board, right_shift)

    # 上
    up_shift = ->(shift_board) { shift_board << 8 }
    legal_board |= legal_board(board.player_board, vertical_watch_board, blank_board, up_shift)

    # 下
    down_shift = ->(shift_board) { shift_board >> 8 }
    legal_board |= legal_board(board.player_board, vertical_watch_board, blank_board, down_shift)

    # 右斜め上
    right_up_shift = ->(shift_board) { shift_board << 7 }
    legal_board |= legal_board(board.player_board, all_side_watch_board, blank_board, right_up_shift)

    # 左斜め上
    left_up_shift = ->(shift_board) { shift_board << 9 }
    legal_board |= legal_board(board.player_board, all_side_watch_board, blank_board, left_up_shift)

    # 右斜め下
    right_down_shift = ->(shift_board) { shift_board >> 9 }
    legal_board |= legal_board(board.player_board, all_side_watch_board, blank_board, right_down_shift)

    # 左斜め下
    left_down_shift = ->(shift_board) { shift_board >> 7 }
    legal_board |= legal_board(board.player_board, all_side_watch_board, blank_board, left_down_shift)

    legal_board
  end

  def legal_board(player_board, opponent_board, blank_board, shift)
    tmp = opponent_board & shift.call(player_board)
    tmp |= opponent_board & shift.call(tmp)
    tmp |= opponent_board & shift.call(tmp)
    tmp |= opponent_board & shift.call(tmp)
    tmp |= opponent_board & shift.call(tmp)
    tmp |= opponent_board & shift.call(tmp)
    blank_board & shift.call(tmp)
  end

  # 反転箇所を求める
  # put 着手した場所のビット値
  # k   反転方向(8つ)
  # return 反転箇所にフラグが立っている64ビット
  def transfer(put:, k:)
    case k
    when 0 then # 上
      (put << 8) & 0xffffffffffffff00
    when 1 then # 右上
      (put << 7) & 0x7f7f7f7f7f7f7f00
    when 2 then # 右
      (put >> 1) & 0x7f7f7f7f7f7f7f7f
    when 3 then # 右下
      (put >> 9) & 0x007f7f7f7f7f7f7f
    when 4 then # 下
      (put >> 8) & 0x00ffffffffffffff
    when 5 then # 左下
      (put >> 7) & 0x00fefefefefefefe
    when 6 then # 左
      (put << 1) & 0xfefefefefefefefe
    when 7 then # 左上
      (put << 9) & 0xfefefefefefefe00
    else
      0
    end
  end
end
