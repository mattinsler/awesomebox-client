class App.UpdateDialog extends App.Dialog
  template: @template('update')
  initialize: -> Spellbinder.initialize(@, replace: true)
  
  render: ->
    log_channel = '/awesomebox/update/' + parseInt(Math.random() * 10000000)
    App.faye.subscribe log_channel, (data) =>
      @$('.status').html(data.status)
    
    App.rpc.call 'awesomebox:update', {log_channel: log_channel}, (err, updated) ->
      return @$('.status').html(err.toString()).toggleClass('error', true) if err?
      
      App.faye.unsubscribe(log_channel)
      setTimeout =>
        if updated
          window.close()
        else
          @hide()
      , 2000
