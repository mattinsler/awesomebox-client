class VersionView extends Backbone.View
  template: @template('app/version')
  initialize: -> Spellbinder.initialize(@, replace: true)
  start: ->
  stop: ->
  open_remote: ->

class App.AppVersionsView extends Backbone.View
  template: @template('app/versions')
  initialize: ->
    Spellbinder.initialize(@)
    @model.versions ?= new App.VersionCollection([], app: @model)
    @model.versions.fetch()
  
  render: ->
    @running_versions_view = new CollectionView(
      el: @$('.version-list.running')
      collection: @model.versions
      item_view: VersionView
      filter: (version) -> version.get('running')
    )
    @not_running_versions_view = new CollectionView(
      el: @$('.version-list.not-running')
      collection: @model.versions
      item_view: VersionView
      filter: (version) -> !version.get('running')
    )
    
    @running_versions_view.render()
    @not_running_versions_view.render()
