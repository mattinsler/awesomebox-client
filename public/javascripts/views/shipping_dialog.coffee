class App.ShippingDialog extends App.Dialog
  template: @template('shipping')
  initialize: -> Spellbinder.initialize(@, replace: true)
