class App.AppView extends Backbone.View
  template: @template('app/app')
  events:
    'show.bs.tab': 'show_tab'
  initialize: ->
    Spellbinder.initialize(@)
  
  show_tab: (e) ->
    tab = $(e.target).data('target').slice(1)
    if tab is 'versions'
      @app_versions_view?.remove()
      
      @app_versions_view = new App.AppVersionsView(model: @model).render()
      @$('#versions').append(@app_versions_view.el)
  
  open_local_site: ->
    
  start_stop: ->
    
  open_folder: ->
    
  ship: ->
    
