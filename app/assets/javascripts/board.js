const cell_px = 80;
const base_point_bit = 0x80000000;
const color_num = {black: '#333', white: '#FFF'};
let black_stones = [];
let white_stones = [];

$(window).on('load', function () {
    let board = document.getElementsByClassName('board');
    $(board).on('click', function (event) {
        let offset =$(this).offset();
        let x = Math.floor((event.pageX - offset.left) / cell_px);
        let y = Math.floor((event.pageY - offset.top) / cell_px);
        let point = String.fromCharCode(x + 'A'.charCodeAt(0)) + String(y + 1);
        App.game.put_stone(point);
    });
    update_latest();
});

function stone(point_index, color) {
    let circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    circle.setAttribute('cx', (point_index % 8) * cell_px + cell_px / 2);
    circle.setAttribute('cy', (point_index / 8 | 0) * cell_px + cell_px / 2);
    circle.setAttribute('r', 32);
    circle.setAttribute('fill', color);
    circle.setAttribute('stroke', color_num.black);
    return circle;
}

function clear_board() {
    $('#view_board').html('');
    $('#template_board > svg').clone(true).appendTo('#view_board');
    $('#view_board > svg').show();
}

function update_board() {
    clear_board();
    let board = document.createDocumentFragment();
    for (let i = 0; i < 32; i++) {
        let point_bit = (base_point_bit >>> i);
        if ((point_bit & black_stones[0]) !== 0) {
            board.appendChild(stone(i, color_num.black));
        }
        if ((point_bit & black_stones[1]) !== 0) {
            board.appendChild(stone(i + 32, color_num.black));
        }
        if ((point_bit & white_stones[0]) !== 0) {
            board.appendChild(stone(i, color_num.white));
        }
        if ((point_bit & white_stones[1]) !== 0) {
            board.appendChild(stone(i + 32, color_num.white));
        }
    }
    document.querySelector('#view_board > svg').appendChild(board);
}

function update_latest() {
    $.ajax({
        url: 'top/latest',
        type: 'GET',
        success: function (data) {
            receive_game(data);
        },
        error: function (data) {
            console.log('get_now error');
        }
    });
}

function receive_game(data) {
    black_stones = change_32bits(data['game']['black_stones']);
    white_stones = change_32bits(data['game']['white_stones']);
    update_board();
}

function change_32bits(bit_stones) {
    let bit_32 = bit_stones.match(/.{8}/g);
    return [parseInt(bit_32[0], 16), parseInt(bit_32[1], 16)];
}
