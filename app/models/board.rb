class Board
  attr_accessor :player_stones, :opponent_stones

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

  def initialize(player_stones: 0x0000000810000000, opponent_stones: 0x0000001008000000)
    # 着手しようとしてる側の石
    @player_stones = player_stones
    # 着手しようとしてる側から見て相手の石
    @opponent_stones = opponent_stones
  end

  # 座標をbitに変換する
  # A1～H8
  def point_to_bit(point)
    x, y = point.split(//)
    0x8000000000000000 >> (x.ord - 'A'.ord) >> ( (y.to_i - 1) * 8)
  end

  # 着手可否の判定
  def can_put?(put)
    put_stone = point_to_bit(put)
    put_stone & can_put_cells != 0
  end

  # 着手して石返しする
  def reverse(put)
    put_stone = point_to_bit(put)
    reversed_stones = reversed_stones(put_stone)
    @player_stones ^= put_stone | reversed_stones
    @opponent_stones ^= reversed_stones
  end

  # パスか？
  def pass?
    can_put_cells == 0
  end

  # 相手側のボード
  def opponent_board
    Board.new(player_stones: @opponent_stones, opponent_stones: @player_stones)
  end

  private

  # 着手可能マス
  def can_put_cells
    DIRECTIONS.values.map do |direction|
      board = adjacent_opponents(direction, @player_stones)
      # 最後が空きマスなら着手可能マスとする
      blank_cells & direction[:shift].call(board)
    end.inject(:|)
  end

  # 石返し対象
  def reversed_stones(put)
    DIRECTIONS.values.map do |direction|
      board = adjacent_opponents(direction, put)
      # 最後に種石があれば石返し対象とする
      @player_stones & direction[:shift].call(board) != 0 ? board : 0
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
    direction[:shift].call(board) & @opponent_stones & direction[:guard]
  end

  # 空きマス
  def blank_cells
    ~(@player_stones | @opponent_stones)
  end
end
