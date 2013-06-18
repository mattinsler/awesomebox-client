class App.Dialog extends Backbone.View
  show: ->
    $('body').append(@el)
    @$el.modal(keyboard: false)
    @$el.on 'hidden.bs.modal', => @remove()
  
  hide: ->
    @$el.modal('hide')
