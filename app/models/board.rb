class Board
  # 現在の手番, 現在何手目か, player側ビットボード, opponent側ビットボード
  attr_accessor :now_turn, :now_index, :player_board, :opponent_board

  # MARK: Constant
  BLACK_TURN = 100
  WHITE_TURN = -100

  DIRECTIONS = {
      top: {
          shift: ->(board) { board << 8 },
          guard: 0xffffffffffffff00
      },
      down: {
          shift: ->(board) { board >> 8 },
          guard: 0x00ffffffffffffff
      },
      left: {
          shift: ->(board) { board << 1 },
          guard: 0xfefefefefefefefe
      },
      right: {
          shift: ->(board) { board >> 1 },
          guard: 0x7f7f7f7f7f7f7f7f
      },
      top_left: {
          shift: ->(board) { board << 9 },
          guard: 0xfefefefefefefe00
      },
      top_right: {
          shift: ->(board) { board << 7 },
          guard: 0x7f7f7f7f7f7f7f00
      },
      down_left: {
          shift: ->(board) { board >> 7 },
          guard: 0x00fefefefefefefe
      },
      down_right: {
          shift: ->(board) { board >> 9 },
          guard: 0x007f7f7f7f7f7f7f
      }
  }.freeze

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
  # put 着手したマス
  def can_put?(put)
    # 着手可能なマスにフラグが立っている合法手ボードを生成
    legal_board = DIRECTIONS.values.map(&method(:legal_board)).inject(:|)
    # 今回の着手が、その合法手ボードに含まれれば着手可能
    put & legal_board == put
  end

  # 着手し,反転処理を行う
  # put: 着手したマス
  def reverse(put)
    # 着手した場合のボードを生成
    transfer_board = DIRECTIONS.values.map { |direction| transfer_board(direction, put) }.inject(:|)
    # 反転する
    @player_board   ^= put | transfer_board
    @opponent_board ^= transfer_board
    # 現在何手目かを更新
    @now_index += 1
  end

  private

  # 着手可能マス
  def legal_board(direction)
    board = adjacent_opponents(direction, @player_board)
    blank_board & direction[:shift].call(board)
  end

  # ひっくり返す石
  def transfer_board(direction, put)
    board = adjacent_opponents(direction, put)
    @player_board & direction[:shift].call(board) != 0 ? board : 0
  end

  # 空きマスのみにビットが立っているボード
  def blank_board
    ~(@player_board | @opponent_board)
  end

  # 指定方向に連続して隣接する相手石
  # 初回とその結果を踏まえながらの最大5回分
  def adjacent_opponents(direction, board)
    (0..4).inject(adjacent_opponent(direction, board)) do |tmp_board, i|
      tmp_board | adjacent_opponent(direction, tmp_board)
    end
  end

  # 指定方向に1マス隣接する相手石
  # ガードを付けることで盤面ループした判定を防ぐ
  def adjacent_opponent(direction, board)
    direction[:shift].call(board) & @opponent_board & direction[:guard]
  end
end
