require 'rails_helper'

RSpec.describe Board, type: :model do
  describe 'coordinate_to_bit' do
    subject { Board.new.coordinate_to_bit(x, y) }
    context 'F5' do
      let(:x) { 'F' }
      let(:y) { '5' }
      let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
      let(:x) { 'C' }
      let(:y) { '3' }
      let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
      let(:x) { 'H' }
      let(:y) { '8' }
      let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
      let(:x) { 'A' }
      let(:y) { '1' }
      let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
        let(:put) {board.coordinate_to_bit('F', '5')}
        it { expect(subject).to be_truthy }
      end
      context 'F4' do
        let(:put) {board.coordinate_to_bit('F', '4')}
        it { expect(subject).to be_falsey }
      end
      context 'F3' do
        let(:put) {board.coordinate_to_bit('F', '3')}
        it { expect(subject).to be_falsey }
      end
      context 'E3' do
        let(:put) {board.coordinate_to_bit('E', '3')}
        it { expect(subject).to be_falsey }
      end
      context 'D3' do
        let(:put) {board.coordinate_to_bit('D', '3')}
        it { expect(subject).to be_truthy }
      end
      context 'C3' do
        let(:put) {board.coordinate_to_bit('C', '3')}
        it { expect(subject).to be_falsey }
      end
      context 'C4' do
        let(:put) {board.coordinate_to_bit('C', '4')}
        it { expect(subject).to be_truthy }
      end
      context 'C5' do
        let(:put) {board.coordinate_to_bit('C', '5')}
        it { expect(subject).to be_falsey }
      end
      context 'C6' do
        let(:put) {board.coordinate_to_bit('C', '6')}
        it { expect(subject).to be_falsey }
      end
      context 'D6' do
        let(:put) {board.coordinate_to_bit('D', '6')}
        it { expect(subject).to be_falsey }
      end
      context 'E6' do
        let(:put) {board.coordinate_to_bit('E', '6')}
        it { expect(subject).to be_truthy }
      end
      context 'F6' do
        let(:put) {board.coordinate_to_bit('F', '6')}
        it { expect(subject).to be_falsey }
      end
    end
  end

  describe 'reverse' do
    subject { board.reverse(put) }
    context '初期配置' do
      let(:board) { Board.new }
      context 'F5' do
        let(:put) { board.coordinate_to_bit('F', '5') }
        let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
        let(:put) { board.coordinate_to_bit('D', '3') }
        let(:expected) do <<-BOARD.gsub(/[\r\n]/,"").to_i(2)
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
  end
end
