const cell_px = 80;
const color_num = {black: '#333', white: '#FFF'};
const init_stones = [{point: 'D4', color: 'white'}, {point: 'E4', color: 'black'},
    {point: 'D5', color: 'black'}, {point: 'E5', color: 'white'}];
var current_stones = [];
var turn;

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

function stone(point, color) {
    var circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    circle.setAttribute('cx', (point.charCodeAt(0) - 'A'.charCodeAt(0)) * cell_px + cell_px / 2);
    circle.setAttribute('cy', (point.charAt(1) - 1) * cell_px + cell_px / 2);
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
    current_stones = init_stones;
    turn = 'black';
    update_board();
}

function update_board() {
    clear_board();
    var board = document.createDocumentFragment();
    $.each(current_stones, function (index, val) {
        board.appendChild(stone(val.point, color_num[val.color]));
    });
    document.querySelector('#view_board > svg').appendChild(board);
}

function send_put(point) {
    $.ajax({
        url: 'top/put_stone',
        type: 'POST',
        data: {
            'point': point,
            'turn': turn
        },
        dataType: 'json',
        success: function (data) {
            turn = data['turn'];
            current_stones = data['stones'];
            update_board();
        },
        error: function (data) {
            alert('error');
        }
    });
}
