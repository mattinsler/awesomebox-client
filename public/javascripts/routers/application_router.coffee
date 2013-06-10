class App.ApplicationRouter extends Backbone.Router
  initialize: ->
    $('body').html('<header></header><div id="drawer"></div><div id="content"></div>')
    @header_view = new App.HeaderView(el: 'header').render()
    @drawer_view = new App.DrawerView(el: '#drawer').render()

  routes:
    ':id': 'show_app'
    '*anything': 'index'
  
  show_app: (id) ->
    app = App.apps.get(id)
    return unless app?
    
    @app_view?.remove()
    App.set(app: app)
    @app_view = new App.AppView(model: app).render()
    
    $('#content').append(@app_view.el)
  
  index: ->
    console.log 'index'
