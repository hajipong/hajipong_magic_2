App.lobby = App.cable.subscriptions.create 'GameChannel',
  connected: ->
  # Called when the subscription is ready for use on the server

  disconnected: ->
  # Called when the subscription has been terminated by the server

  received: (data) ->
    receive_game(data)