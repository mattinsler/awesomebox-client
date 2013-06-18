class App.AppView extends Backbone.View
  template: @template('app/app')
  events:
    'show.bs.tab': 'show_tab'
  initialize: ->
    Spellbinder.initialize(@)
    @model.on('change', @render, @)
    @model.on 'change:is_shipping', =>
      @dialog ?= new App.ShippingDialog(model: @model).render()
      if @model.get('is_shipping')
        @dialog.show()
      else
        @dialog.hide()
  
  render: ->
    setTimeout(prettyPrint, 1)
  
  show_tab: (e) ->
    tab = $(e.target).data('target').slice(1)
    if tab is 'versions'
      @app_versions_view?.remove()
      
      @app_versions_view = new App.AppVersionsView(model: @model).render()
      @$('#versions').append(@app_versions_view.el)
  
  open_local: ->
    App.rpc.call('apps:open_local', id: @model.id)
  
  start_local: ->
    App.rpc.call('apps:start_local', id: @model.id)
  
  stop_local: ->
    App.rpc.call('apps:stop_local', id: @model.id)
    
  open_folder: ->
    App.rpc.call('apps:open_folder', id: @model.id)
    
  ship: ->
    # App.faye.publish("/command/app/#{@model.id}", type: 'app', id: @model.id, method: 'ship')
