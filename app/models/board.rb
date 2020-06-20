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
    # 隣に相手の色があるかを一時保存する
    tmp = nil
    # 返り値
    legal_board = nil

    # 8方向チェック
    # ・一度に返せる石は最大6つ ・高速化のためにforを展開(ほぼ意味ないけどw)
    # 左
    tmp = horizontal_watch_board & (board.player_board << 1)
    tmp |= horizontal_watch_board & (tmp << 1)
    tmp |= horizontal_watch_board & (tmp << 1)
    tmp |= horizontal_watch_board & (tmp << 1)
    tmp |= horizontal_watch_board & (tmp << 1)
    tmp |= horizontal_watch_board & (tmp << 1)
    legal_board = blank_board & (tmp << 1)

    # 右
    tmp = horizontal_watch_board & (board.player_board >> 1)
    tmp |= horizontal_watch_board & (tmp >> 1)
    tmp |= horizontal_watch_board & (tmp >> 1)
    tmp |= horizontal_watch_board & (tmp >> 1)
    tmp |= horizontal_watch_board & (tmp >> 1)
    tmp |= horizontal_watch_board & (tmp >> 1)
    legal_board |= blank_board & (tmp >> 1)

    # 上
    tmp = vertical_watch_board & (board.player_board << 8)
    tmp |= vertical_watch_board & (tmp << 8)
    tmp |= vertical_watch_board & (tmp << 8)
    tmp |= vertical_watch_board & (tmp << 8)
    tmp |= vertical_watch_board & (tmp << 8)
    tmp |= vertical_watch_board & (tmp << 8)
    legal_board |= blank_board & (tmp << 8)

    # 下
    tmp = vertical_watch_board & (board.player_board >> 8)
    tmp |= vertical_watch_board & (tmp >> 8)
    tmp |= vertical_watch_board & (tmp >> 8)
    tmp |= vertical_watch_board & (tmp >> 8)
    tmp |= vertical_watch_board & (tmp >> 8)
    tmp |= vertical_watch_board & (tmp >> 8)
    legal_board |= blank_board & (tmp >> 8)

    # 右斜め上
    tmp = all_side_watch_board & (board.player_board << 7)
    tmp |= all_side_watch_board & (tmp << 7)
    tmp |= all_side_watch_board & (tmp << 7)
    tmp |= all_side_watch_board & (tmp << 7)
    tmp |= all_side_watch_board & (tmp << 7)
    tmp |= all_side_watch_board & (tmp << 7)
    legal_board |= blank_board & (tmp << 7)

    # 左斜め上
    tmp = all_side_watch_board & (board.player_board << 9)
    tmp |= all_side_watch_board & (tmp << 9)
    tmp |= all_side_watch_board & (tmp << 9)
    tmp |= all_side_watch_board & (tmp << 9)
    tmp |= all_side_watch_board & (tmp << 9)
    tmp |= all_side_watch_board & (tmp << 9)
    legal_board |= blank_board & (tmp << 9)

    # 右斜め下
    tmp = all_side_watch_board & (board.player_board >> 9)
    tmp |= all_side_watch_board & (tmp >> 9)
    tmp |= all_side_watch_board & (tmp >> 9)
    tmp |= all_side_watch_board & (tmp >> 9)
    tmp |= all_side_watch_board & (tmp >> 9)
    tmp |= all_side_watch_board & (tmp >> 9)
    legal_board |= blank_board & (tmp >> 9)

    # 左斜め下
    tmp = all_side_watch_board & (board.player_board >> 7)
    tmp |= all_side_watch_board & (tmp >> 7)
    tmp |= all_side_watch_board & (tmp >> 7)
    tmp |= all_side_watch_board & (tmp >> 7)
    tmp |= all_side_watch_board & (tmp >> 7)
    tmp |= all_side_watch_board & (tmp >> 7)
    legal_board |= blank_board & (tmp >> 7)

    legal_board
  end
end