App.game = App.cable.subscriptions.create('GameChannel', {
  connected: function() {},

  disconnected: function() {},

  received: function(data) {
      receive_game(data);
  },

  put_stone: function(point) {
      return this.perform('put_stone',{point: point, game_table_id: $('#game_table_id').val()});
  }
});