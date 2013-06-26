class VersionView extends Backbone.View
  template: @template('app/version')
  initialize: -> Spellbinder.initialize(@, replace: true)
  
  disable: ->
    @$('.btn:first').prop('disabled', true)
  
  enable: ->
    @$('.btn:first').prop('disabled', false)
  
  start: ->
    @disable()
    App.client.post "/apps/#{@model.get('instance').app}/versions/#{@model.get('instance').version}/start", (err, data) =>
      console.log arguments
      @model.set(data) if data?
      @enable()
  stop: ->
    @disable()
    App.client.post "/apps/#{@model.get('instance').app}/versions/#{@model.get('instance').version}/stop", (err, data) =>
      console.log arguments
      @model.set(data) if data?
      @enable()
  open_remote: ->
    App.raw_client.post('/commands/open', url: 'http://' + _(@model.get('domains')).last())

class App.AppVersionsView extends Backbone.View
  template: @template('app/versions')
  initialize: ->
    Spellbinder.initialize(@)
    @model.versions ?= new App.VersionCollection([], app: @model)
    @model.versions.fetch()
    
    @model.versions.on('change', @refresh_collections, @)
  
  refresh_collections: ->
    @running_versions_view.render()
    @not_running_versions_view.render()
  
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
    
    @refresh_collections()
