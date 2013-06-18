class AppItemView extends Backbone.View
  template: @template('drawer-app')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
  
  select: ->
    Backbone.history.navigate(@model.id, true)

class App.DrawerView extends Backbone.View
  template: @template('drawer')
  initialize: ->
    Spellbinder.initialize(@, replace: true)
    App.on('change:online', @update_collections, @)
    App.apps.on('change', @update_collections, @)
  
  update_collections: ->
    @shipped_apps_view.render()
    @local_apps_view.render()
  
  render: ->
    @shipped_apps_view ?= new CollectionView(
      el: @$('.shipped-apps')
      item_view: AppItemView
      collection: App.apps
      filter: (app) -> app.get('is_remote') and App.get('online')
    )
    @local_apps_view ?= new CollectionView(
      el: @$('.local-apps')
      item_view: AppItemView
      collection: App.apps
      filter: (app) -> app.get('is_local')
    )
    @update_collections()
  
  new_app: ->
    new App.NewAppDialog().render().show()
