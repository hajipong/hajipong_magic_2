class Board
  # 現在の手番, 現在何手目か, player側ビットボード, opponent側ビットボード
  attr_accessor :now_turn, :now_index, :player_board, :opponent_board

  # MARK: Constant
  BLACK_TURN = 100
  WHITE_TURN = -100
  HORIZONTAL_GUARD = 0x7e7e7e7e7e7e7e7e
  VERTICAL_GUARD = 0x00FFFFFFFFFFFF00
  ALL_SIDE_GUARD= 0x007e7e7e7e7e7e00
  DIRECTIONS = {
      top:        { shift: ->(board) { board << 8 }, guard: VERTICAL_GUARD },
      down:       { shift: ->(board) { board >> 8 }, guard: VERTICAL_GUARD },
      left:       { shift: ->(board) { board << 1 }, guard: HORIZONTAL_GUARD },
      right:      { shift: ->(board) { board >> 1 }, guard: HORIZONTAL_GUARD },
      top_left:   { shift: ->(board) { board << 9 }, guard: ALL_SIDE_GUARD },
      top_right:  { shift: ->(board) { board << 7 }, guard: ALL_SIDE_GUARD },
      down_left:  { shift: ->(board) { board >> 7 }, guard: ALL_SIDE_GUARD },
      down_right: { shift: ->(board) { board >> 9 }, guard: ALL_SIDE_GUARD }
  }.freeze

  def initialize(player_board: 0x0000000810000000, opponent_board: 0x0000001008000000)
    @now_turn = BLACK_TURN
    @now_index = 1

    # 一般的な初期配置を指定
    @player_board = player_board
    @opponent_board = opponent_board
  end

  # 座標をbitに変換する
  # x 横座標(A~H)
  # y 縦座標(1~8)
  # return 着手箇所のみにフラグが立っている64ビット
  def coordinate_to_bit(point)
    x, y = point.split(//)
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

  def pass?
    legal_board == 0 && to_opponent.legal_board != 0
  end

  def game_finished?
    legal_board == 0 && to_opponent.legal_board == 0
  end

  def swap_board
    tmp = @player_board
    @player_board = @opponent_board
    @opponent_board = tmp
    @now_turn = @now_turn * -1
  end

  # 着手可能マス
  def legal_board
    DIRECTIONS.values.map(&method(:legal_board_direction)).inject(:|)
  end

  def to_opponent
    tmp_board = Board.new
    tmp_board.now_turn = @now_turn
    tmp_board.now_index = @now_index
    tmp_board.player_board = @opponent_board
    tmp_board.opponent_board = @player_board
    tmp_board
  end

  private

  # 着手可能マス(一方向)
  def legal_board_direction(direction)
    board = adjacent_opponents(direction, @player_board)
    blank_board & direction[:shift].call(board)
  end

  # ひっくり返す石(一方向)
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
