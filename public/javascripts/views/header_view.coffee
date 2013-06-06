class App.HeaderView extends Backbone.View
  template: @template('header')
  initialize: -> Spellbinder.initialize(@, replace: true)
