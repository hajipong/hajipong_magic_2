const brack = '#333';
const white = '#FFF';
const cell_px = 80;
const color_num = { brack: '#333', white: '#FFF' };
const init_stones = [{ point: 'D4', color: 'white'}, { point: 'E4', color: 'brack'}, { point: 'D5', color: 'brack'}, { point: 'E5', color: 'white'}];
var current_stones = [];

$(window).on('load', function () {
    var classname = document.getElementsByClassName('hoge');
    $(classname).on('click', function ( event ) {
        var clientRect = this.getBoundingClientRect() ;
        var x = Math.ceil((event.pageX - clientRect.left + window.pageXOffset) / cell_px);
        var y = Math.ceil((event.pageY - clientRect.top + window.pageYOffset) / cell_px);
        point = String.fromCharCode(x + 64) + String(y);
        send_put(point, 'brack');
    });
});

function view_board_dom() {
    return document.querySelector('#view_board > svg');
}

function stone(position, color) {
    circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    circle.setAttribute('cx', (position.charCodeAt(0) - 65) * cell_px + cell_px / 2);
    circle.setAttribute('cy', (position.charAt(1) - 1) * cell_px + cell_px / 2);
    circle.setAttribute('r', 32);
    circle.setAttribute('fill', color);
    circle.setAttribute('stroke', '#333');
    return circle;
}

function clear_board() {
    $('#view_board').html('');
    $('#template_board > svg').clone(true).appendTo('#view_board');
    $('#view_board > svg').show();
}

$(".init").click(function () {
    clear_board();
    current_stones = init_stones;
    update_board();
});

function update_board() {
    clear_board();
    $.each(current_stones, function(index, val){
        view_board_dom().appendChild(stone(val.point, color_num[val.color]));
    });
}

function send_put(point, color) {
    $.ajax({
        url: 'top/put_stone',
        type:'POST',
        data:{
            'point': point,
            'color': 'brack',
            'stones': current_stones
        },
        dataType: 'json',
        success: function(data) {
            current_stones = data;
            update_board();
        },
        error: function(data) {
            alert('error');
        }
    });
}

