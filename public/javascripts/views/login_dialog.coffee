class App.LoginDialog extends Backbone.View
  template: @template('login')
  initialize: -> Spellbinder.initialize(@, replace: true)
  
  show: ->
    $('body').append(@el)
    @$el.modal(keyboard: false)
    @$el.on 'hidden.bs.modal', => @remove()
  
  enable: -> @$('input').prop(disabled: false)
  disable: -> @$('input').prop(disabled: true)
  
  cancel: ->
    @$el.modal('hide')
  
  on_submit: (e) ->
    e.preventDefault()
    
    config = $('form').serializeObject()
    @disable()
    
    App.login config, (err, user) =>
      return @$el.modal('hide') if user?
      @enable()
      @$('.alert').slideDown()
    
    false
