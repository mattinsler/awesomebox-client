class App.DrawerView extends Backbone.View
  template: @template('drawer')
  initialize: -> Spellbinder.initialize(@, replace: true)
