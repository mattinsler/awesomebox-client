class App.ShippingDialog extends App.Dialog
  template: @template('shipping')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
  
  on_submit: (e) ->
    e.preventDefault()
    
    data = @$('form').serializeObject()
    @ship(data)
    
    false
  
  ship: (opts) ->
    @$('textarea, [type="button"], [type="submit"]').prop('disabled', true)
    @$('.status').slideDown()
    
    log_channel = '/apps/ship/' + parseInt(Math.random() * 10000000)
    App.faye.subscribe log_channel, (data) =>
      @$('.status').html(data.status)
    
    App.rpc.call 'apps:ship', {id: @model.id, log_channel: log_channel, comment: opts.comment}, (err, version) =>
      console.log arguments
      
      if err?
        @$('textarea, [type="button"], [type="submit"]').prop('disabled', false)
        return @$('.status').html(err.toString()).toggleClass('error', true)
      
      App.faye.unsubscribe(log_channel)
      @$('.status').html('Yay! Your app has shipped!')
      setTimeout =>
        @hide()
      , 2000
