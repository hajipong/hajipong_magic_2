const cell_px = 80;
const base_point_bit = 0x80000000;
const color_num = {black: '#333', white: '#FFF'};
var black_stones = [];
var white_stones = [];

$(window).on('load', function () {
    init();
    var board = document.getElementsByClassName('board');
    $(board).on('click', function (event) {
        var clientRect = this.getBoundingClientRect();
        var x = Math.floor((event.pageX - clientRect.left + window.pageXOffset) / cell_px);
        var y = Math.floor((event.pageY - clientRect.top + window.pageYOffset) / cell_px);
        var point = String.fromCharCode(x + 'A'.charCodeAt(0)) + String(y + 1);
        send_put(point);
    });
});

function stone(point_index, color) {
    var circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
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

$('.init').click(function () {
    init();
});

function init() {
    black_stones = [0x00000008, 0x10000000];
    white_stones = [0x00000010, 0x08000000];
    update_board();
}

function update_board() {
    clear_board();
    var board = document.createDocumentFragment();
    for (var i = 0; i < 32; i++) {
        var point_bit = (base_point_bit >>> i);
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

function send_put(point) {
    $.ajax({
        url: 'top/put_stone',
        type: 'POST',
        data: {
            'point': point
        },
        dataType: 'json',
        success: function (data) {
            black_stones = change_32bits(data['black_stones']);
            white_stones = change_32bits(data['white_stones']);
            update_board();
        },
        error: function (data) {
            alert('error');
        }
    });
}

function change_32bits(bit_stones) {
    bit_32 = bit_stones.match(/.{8}/g);
    return [parseInt(bit_32[0], 16), parseInt(bit_32[1], 16)];
}
