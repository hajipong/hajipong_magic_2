var brack = '#333';
var white = '#FFF';

function view_board_dom() {
    return document.querySelector('#view_board > svg');
}

function stone(position, color) {
    circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    circle.setAttribute('cx', (position.charCodeAt(0) - 65) * 80 + 40);
    circle.setAttribute('cy', (position.charAt(1) - 1) * 80 + 40);
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
    view_board_dom().appendChild(stone('D4', white));
    view_board_dom().appendChild(stone('E4', brack));
    view_board_dom().appendChild(stone('D5', brack));
    view_board_dom().appendChild(stone('E5', white));
});