class App.HeaderView extends Backbone.View
  template: @template('header')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
    App.on('change:online', @render, @)
  
  login: -> new App.LoginDialog().render().show()
  logout: -> App.logout()
  
  account: ->
  preferences: ->
