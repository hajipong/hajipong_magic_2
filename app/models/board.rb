class Board
  # player側ビットボード, opponent側ビットボード
  attr_accessor :player_board, :opponent_board

  HORIZONTAL_GUARD = 0x7e7e7e7e7e7e7e7e.freeze
  VERTICAL_GUARD = 0x00FFFFFFFFFFFF00.freeze
  ALL_SIDE_GUARD= 0x007e7e7e7e7e7e00.freeze
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
    @player_board = player_board
    @opponent_board = opponent_board
  end

  # 座標をbitに変換する
  # x 横座標(A~H)
  # y 縦座標(1~8)
  def coordinate_to_bit(point)
    x, y = point.split(//)
    mask = 0x8000000000000000
    mask = mask >> (x.ord - 'A'.ord)
    mask >> ( (y.to_i - 1) * 8)
  end

  # 着手可否の判定
  def can_put?(put)
    put & legal_board != 0
  end

  # 着手し,反転処理を行う
  def reverse(put)
    transfer_board = transfer_board(put)
    @player_board ^= put | transfer_board
    @opponent_board ^= transfer_board
  end

  def pass?
    legal_board == 0
  end

  # 相手側のボード
  def to_opponent
    Board.new(player_board: @opponent_board, opponent_board: @player_board)
  end

  private

  # 着手可能マス
  def legal_board
    DIRECTIONS.values.map do |direction|
      board = adjacent_opponents(direction, @player_board)
      # 最後が空きマスなら着手できる
      blank_board & direction[:shift].call(board)
    end.inject(:|)
  end

  # ひっくり返す石
  def transfer_board(put)
    DIRECTIONS.values.map do |direction|
      board = adjacent_opponents(direction, put)
      # 最後に種石があればひっくり返しできる
      @player_board & direction[:shift].call(board) != 0 ? board : 0
    end.inject(:|)
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

  # 空きマス
  def blank_board
    ~(@player_board | @opponent_board)
  end
end
