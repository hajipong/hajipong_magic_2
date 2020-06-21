require 'rails_helper'

RSpec.describe Board, type: :model do
  describe 'coordinate_to_bit' do
    subject { Board.new.coordinate_to_bit(point) }
    context 'F5' do
      let(:point) { 'F5' }
      let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        00000000
        00000000
        00000100
        00000000
        00000000
        00000000
        BOARD
      end
      it '左から6、上から5' do
        expect(subject).to eq(expected)
      end
    end

    context 'C3' do
      let(:point) { 'C3' }
      let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        00100000
        00000000
        00000000
        00000000
        00000000
        00000000
        BOARD
      end
      it '左から3、上から3' do
        expect(subject).to eq(expected)
      end
    end

    context 'H8' do
      let(:point) { 'H8' }
      let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        00000000
        00000000
        00000000
        00000000
        00000000
        00000001
        BOARD
      end
      it '左から8、上から8' do
        expect(subject).to eq(expected)
      end
    end

    context 'A1' do
      let(:point) { 'A1' }
      let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        10000000
        00000000
        00000000
        00000000
        00000000
        00000000
        00000000
        00000000
        BOARD
      end
      it '左から1、上から1' do
        expect(subject).to eq(expected)
      end
    end
  end

  describe 'can_put?' do
    subject { board.can_put?(put) }
    context '初期配置' do
      let(:board) { Board.new }
      context 'F5' do
        let(:put) {board.coordinate_to_bit('F5')}
        it { expect(subject).to be_truthy }
      end
      context 'F4' do
        let(:put) {board.coordinate_to_bit('F4')}
        it { expect(subject).to be_falsey }
      end
      context 'F3' do
        let(:put) {board.coordinate_to_bit('F3')}
        it { expect(subject).to be_falsey }
      end
      context 'E3' do
        let(:put) {board.coordinate_to_bit('E3')}
        it { expect(subject).to be_falsey }
      end
      context 'D3' do
        let(:put) {board.coordinate_to_bit('D3')}
        it { expect(subject).to be_truthy }
      end
      context 'C3' do
        let(:put) {board.coordinate_to_bit('C3')}
        it { expect(subject).to be_falsey }
      end
      context 'C4' do
        let(:put) {board.coordinate_to_bit('C4')}
        it { expect(subject).to be_truthy }
      end
      context 'C5' do
        let(:put) {board.coordinate_to_bit('C5')}
        it { expect(subject).to be_falsey }
      end
      context 'C6' do
        let(:put) {board.coordinate_to_bit('C6')}
        it { expect(subject).to be_falsey }
      end
      context 'D6' do
        let(:put) {board.coordinate_to_bit('D6')}
        it { expect(subject).to be_falsey }
      end
      context 'E6' do
        let(:put) {board.coordinate_to_bit('E6')}
        it { expect(subject).to be_truthy }
      end
      context 'F6' do
        let(:put) {board.coordinate_to_bit('F6')}
        it { expect(subject).to be_falsey }
      end
    end
  end

  describe 'reverse' do
    subject { board.reverse(put) }
    context '初期配置' do
      let(:board) { Board.new }
      context 'F5' do
        let(:put) { board.coordinate_to_bit('F5') }
        let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
          00000000
          00000000
          00000000
          00001000
          00011100
          00000000
          00000000
          00000000
          BOARD
        end
        it 'E5が返る' do
          subject
          expect(board.player_board).to eq(expected)
        end
      end

      context 'D3' do
        let(:put) { board.coordinate_to_bit('D3') }
        let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
          00000000
          00000000
          00010000
          00011000
          00010000
          00000000
          00000000
          00000000
          BOARD
        end
        it 'D4が返る' do
          subject
          expect(board.player_board).to eq(expected)
        end
      end
    end

    context 'ループ返しチェック' do
      let(:board) { Board.new(player_board: player_board, opponent_board: opponent_board) }
      let(:player_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        01100001
        00000001
        00000001
        00000001
        00000000
        00000000
        00000000
        00001001
        BOARD
      end
      let(:opponent_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00010000
        11100000
        10111110
        11100000
        01010000
        01001000
        01000100
        01000010
        BOARD
      end
      context 'B3' do
        let(:put) { board.coordinate_to_bit('B3') }
        let(:expected) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
          01100001
          01000001
          01111111
          00000001
          00000000
          00000000
          00000000
          00001001
          BOARD
        end
        it '種の無いところが返ってはだめ' do
          subject
          expect(board.player_board).to eq(expected)
        end
      end
    end
  end

  describe 'pass' do
    context '黒番パス' do
      let(:board) do
        b = Board.new
        b.player_board = player_board
        b.opponent_board = opponent_board
        b
      end
      let(:player_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        00001111
        00001000
        00001000
        00001111
        00000000
        00000000
        BOARD
      end
      let(:opponent_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        00000000
        00000111
        00000111
        00000000
        00000000
        00000000
        BOARD
      end
      context '黒番' do
        it 'パス' do
          expect(board.pass?).to be_truthy
        end
      end

      context '白番' do
        it 'パスなし' do
          expect(board.to_opponent.pass?).to be_falsey
        end
      end
    end
  end


  describe 'game_finished?' do
    context '空きマスあり終局' do
      let(:board) do
        b = Board.new
        b.player_board = player_board
        b.opponent_board = opponent_board
        b
      end
      let(:player_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        11111110
        11111111
        00001111
        00001111
        00011111
        00111111
        01111111
        11111111
        BOARD
      end
      let(:opponent_board) do <<~BOARD.gsub(/[\r\n]/,"").to_i(2)
        00000000
        00000000
        11110000
        11110000
        11100000
        11000000
        10000000
        00000000
        BOARD
      end
      it '終局' do
        expect(board.game_finished?).to be_truthy
      end
    end
  end

  def board_to_s(board)
    board.to_s(2).rjust(64, '0')
        .insert(56, "\n").insert(48, "\n").insert(40, "\n")
        .insert(32, "\n").insert(24, "\n").insert(16, "\n").insert(8, "\n")
  end
end
