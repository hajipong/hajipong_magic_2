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
    context '初期配置にF5' do
      let(:board) { Board.new }
      let(:put) {board.coordinate_to_bit('F', '5')}
      it '置ける' do
        expect(subject).to be_truthy
      end
    end

    context '初期配置にF4' do
      let(:board) { Board.new }
      let(:put) {board.coordinate_to_bit('F', '4')}
      it '置けない' do
        expect(subject).to be_falsey
      end
    end
  end
end
