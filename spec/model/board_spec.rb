require 'rails_helper'

RSpec.describe Board, type: :model do
  describe 'coordinate_to_bit' do
    subject { Board.new.point_to_bit(point) }
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
        let(:put) { 'F5' }
        it { expect(subject).to be_truthy }
      end
      context 'F4' do
        let(:put) { 'F4' }
        it { expect(subject).to be_falsey }
      end
      context 'F3' do
        let(:put) { 'F3' }
        it { expect(subject).to be_falsey }
      end
      context 'E3' do
        let(:put) { 'E3' }
        it { expect(subject).to be_falsey }
      end
      context 'D3' do
        let(:put) { 'D3' }
        it { expect(subject).to be_truthy }
      end
      context 'C3' do
        let(:put) { 'C3' }
        it { expect(subject).to be_falsey }
      end
      context 'C4' do
        let(:put) { 'C4' }
        it { expect(subject).to be_truthy }
      end
      context 'C5' do
        let(:put) { 'C5' }
        it { expect(subject).to be_falsey }
      end
      context 'C6' do
        let(:put) { 'C6' }
        it { expect(subject).to be_falsey }
      end
      context 'D6' do
        let(:put) { 'D6' }
        it { expect(subject).to be_falsey }
      end
      context 'E6' do
        let(:put) { 'E6' }
        it { expect(subject).to be_truthy }
      end
      context 'F6' do
        let(:put) { 'F6' }
        it { expect(subject).to be_falsey }
      end
    end
  end

  describe 'reverse' do
    subject { board.reverse(put) }
    context '初期配置' do
      let(:board) { Board.new }
      context 'F5' do
        let(:put) { 'F5' }
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
          expect(board.player_stones).to eq(expected)
        end
      end

      context 'D3' do
        let(:put) { 'D3' }
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
          expect(board.player_stones).to eq(expected)
        end
      end
    end

    context 'ループ返しチェック' do
      let(:board) { Board.new(player_stones: player_stones, opponent_stones: opponent_stones) }
      let(:player_stones) do <<~BOARD.gsub(/[\r\n]/, "").to_i(2)
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
      let(:opponent_stones) do <<~BOARD.gsub(/[\r\n]/, "").to_i(2)
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
        let(:put) { 'B3' }
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
          expect(board.player_stones).to eq(expected)
        end
      end
    end
  end

  describe 'pass' do
    context '黒番パス' do
      let(:board) { Board.new(player_stones: player_stones, opponent_stones: opponent_stones) }
      let(:player_stones) do <<~BOARD.gsub(/[\r\n]/, "").to_i(2)
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
      let(:opponent_stones) do <<~BOARD.gsub(/[\r\n]/, "").to_i(2)
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
          expect(board.opponent_board.pass?).to be_falsey
        end
      end
    end
  end

  def board_to_s(board)
    board.to_s(2).rjust(64, '0')
        .insert(56, "\n").insert(48, "\n").insert(40, "\n")
        .insert(32, "\n").insert(24, "\n").insert(16, "\n").insert(8, "\n")
  end
end
